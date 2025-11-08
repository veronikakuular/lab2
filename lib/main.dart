import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

void main() async {
  // Инициализируем Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Подключаемся к Supabase
  await SupabaseService.initialize();
  
  // Запускаем приложение
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  // Функция для загрузки сообщений из базы данных
  Future<void> _loadMessages() async {
    try {
      // Получаем сообщения из Supabase
      final response = await SupabaseService.client
          .from('messages')
          .select()
          .order('created_at', ascending: false);

      // Обновляем список сообщений
      setState(() {
        _messages.clear();
        _messages.addAll(List<Map<String, dynamic>>.from(response));
      });
    } catch (error) {
      print('Ошибка загрузки сообщений: $error');
    }
  }

  // Функция для отправки сообщения
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    
    // Проверяем, что сообщение не пустое
    if (text.isEmpty) return;

    try {
      // Отправляем сообщение в базу данных
      await SupabaseService.client
          .from('messages')
          .insert({'text': text});

      // Очищаем поле ввода
      _messageController.clear();
      
      // Обновляем список сообщений
      await _loadMessages();
    } catch (error) {
      print('Ошибка отправки сообщения: $error');
    }
  }

  // Функция для форматирования даты
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  // Загружаем сообщения при запуске экрана
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Чат'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Кнопка обновления
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages, // Просто вызываем загрузку сообщений
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: Column(
        children: [
          // Список сообщений
          Expanded(
            child: FutureBuilder<void>(
              future: Future.value(), // Просто для совместимости с FutureBuilder
              builder: (context, snapshot) {
                // Показываем индикатор загрузки
                if (_messages.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Показываем сообщения через List.generate
                return ListView(
                  reverse: true, // Новые сообщения внизу
                  padding: const EdgeInsets.all(16),
                  children: List.generate(_messages.length, (index) {
                    final message = _messages[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          message['text']?.toString() ?? 'Пустое сообщение',
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          _formatDate(message['created_at']?.toString() ?? ''),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          // Поле ввода сообщения
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                // Поле для ввода текста
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Введите ваше сообщение...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) {
                      // Можно добавить логику при изменении текста
                      // Например, проверку длины сообщения
                    },
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Кнопка отправки
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                  tooltip: 'Отправить сообщение',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}