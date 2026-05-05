import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsAnalyzerScreen extends StatefulWidget {
  const SmsAnalyzerScreen({super.key});

  @override
  State<SmsAnalyzerScreen> createState() => _SmsAnalyzerScreenState();
}

class _SmsAnalyzerScreenState extends State<SmsAnalyzerScreen> {
  final Telephony telephony = Telephony.instance;

  List<SmsMessage> _allMessages = [];
  List<SmsMessage> _qcMessages = [];
  List<SmsMessage> _otpMessages = [];

  // Dùng cho tab Thống kê
  List<SmsMessage> _searchedPhoneMessages = [];
  Map<String, int> _messagesByDate = {};
  final TextEditingController _phoneSearchController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
    ].request();
    if (statuses[Permission.sms]!.isGranted) {
      _loadMessages();
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng cấp quyền SMS!')),
        );
      }
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    _allMessages = messages;
    _searchedPhoneMessages =
        messages; // Mặc định hiển thị tất cả ở phần tìm kiếm số ĐT

    _processMessages();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Hàm xử lý phân loại và thống kê
  void _processMessages() {
    _qcMessages.clear();
    _otpMessages.clear();
    _messagesByDate.clear();

    for (var msg in _allMessages) {
      String body = msg.body ?? '';

      // 1. Phân loại QC và OTP
      if (body.startsWith('[QC]')) {
        _qcMessages.add(msg);
      }
      if (body.contains('[OTP]')) {
        _otpMessages.add(msg);
      }

      // 2. Thống kê theo ngày/tháng
      if (msg.date != null) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(msg.date!);
        String dateStr = '${date.day}/${date.month}/${date.year}';
        _messagesByDate[dateStr] = (_messagesByDate[dateStr] ?? 0) + 1;
      }
    }
  }

  // Hàm lọc theo số điện thoại
  void _filterByPhone(String phone) {
    setState(() {
      if (phone.isEmpty) {
        _searchedPhoneMessages = _allMessages;
      } else {
        _searchedPhoneMessages = _allMessages
            .where((msg) => (msg.address ?? '').contains(phone))
            .toList();
      }
    });
  }

  // Hàm trích xuất 6 số từ tin nhắn OTP
  void _extractAndShowOTP(String body) {
    // Dùng Regex tìm đúng chuỗi 6 chữ số liên tiếp
    RegExp regExp = RegExp(r'\d{6}');
    Match? match = regExp.firstMatch(body);

    String otpCode = match != null ? match.group(0)! : 'Không tìm thấy 6 số';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mã OTP trích xuất'),
        content: Text(
          otpCode,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            letterSpacing: 5,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Format ngày để hiển thị trên ListTile
  String _formatDate(int? timestamp) {
    if (timestamp == null) return '';
    DateTime d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${d.day}/${d.month} ${d.hour}:${d.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SMS Analyzer'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.analytics), text: 'Thống kê'),
              Tab(icon: Icon(Icons.campaign), text: 'Quảng cáo'),
              Tab(icon: Icon(Icons.security), text: 'Mã OTP'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildStatsTab(),
                  _buildMessageList(_qcMessages, isOtp: false),
                  _buildMessageList(_otpMessages, isOtp: true),
                ],
              ),
      ),
    );
  }

  // Giao diện Tab 1: Thống kê
  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(
                Icons.mark_email_read,
                size: 40,
                color: Colors.blue,
              ),
              title: const Text(
                'Tổng số tin nhắn nhận được',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                '${_allMessages.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tìm kiếm theo số điện thoại:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneSearchController,
            onChanged: _filterByPhone,
            decoration: InputDecoration(
              hintText: 'Nhập số điện thoại...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tìm thấy: ${_searchedPhoneMessages.length} tin nhắn',
            style: const TextStyle(color: Colors.grey),
          ),
          const Divider(height: 30),
          const Text(
            'Thống kê theo ngày/tháng:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._messagesByDate.entries.map((entry) {
            return ListTile(
              dense: true,
              leading: const Icon(Icons.calendar_today, size: 20),
              title: Text(entry.key),
              trailing: Text(
                '${entry.value} tin nhắn',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Giao diện dùng chung cho danh sách QC và OTP
  Widget _buildMessageList(List<SmsMessage> messages, {required bool isOtp}) {
    if (messages.isEmpty) {
      return const Center(child: Text('Không có tin nhắn nào trong nhóm này.'));
    }
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isOtp ? Colors.green : Colors.orange,
              child: Icon(
                isOtp ? Icons.key : Icons.ad_units,
                color: Colors.white,
              ),
            ),
            title: Text(
              msg.address ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              msg.body ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              _formatDate(msg.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: isOtp ? () => _extractAndShowOTP(msg.body ?? '') : null,
          ),
        );
      },
    );
  }
}
