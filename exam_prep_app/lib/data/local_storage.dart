/// Local data storage for testing without Firebase
/// Replace with Firebase later

class LocalStorage {
  // Singleton pattern
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  // In-memory data stores
  final Map<String, Map<String, dynamic>> _users = {};
  final Map<String, Map<String, dynamic>> _content = {};
  final Map<String, Map<String, dynamic>> _exams = {};
  final Map<String, Map<String, dynamic>> _transactions = {};
  final Map<String, Map<String, dynamic>> _smeWallets = {};
  final Map<String, Map<String, dynamic>> _rewardTransactions = {};
  
  String? _currentUserId;

  // Initialize with sample data
  void initSampleData() {
    // Sample users
    _users['user1'] = {
      'uid': 'user1',
      'email': 'user@test.com',
      'name': 'Test User',
      'points': 250,
      'firstLogin': false,
      'firstTopup': true,
      'role': 'user',
    };
    
    _users['sme1'] = {
      'uid': 'sme1',
      'email': 'sme@test.com',
      'name': 'SME Teacher',
      'points': 0,
      'firstLogin': false,
      'firstTopup': false,
      'role': 'sme',
    };
    
    _users['admin1'] = {
      'uid': 'admin1',
      'email': 'admin@test.com',
      'name': 'Admin',
      'points': 0,
      'firstLogin': false,
      'firstTopup': false,
      'role': 'admin',
    };

    // Sample entrance exams
    _exams['exam1'] = {
      'id': 'exam1',
      'title': 'JEE Main 2025',
      'description': 'Joint Entrance Examination Main 2025',
      'type': 'entrance_exam',
      'category': 'Engineering',
      'questions': [
        {
          'id': 'q1',
          'questionText': 'What is the speed of light in vacuum?',
          'options': ['3×10⁸ m/s', '3×10⁶ m/s', '3×10⁴ m/s', '3×10² m/s'],
          'correctAnswerIndex': 0,
        },
        {
          'id': 'q2',
          'questionText': 'What is the chemical symbol for Gold?',
          'options': ['Go', 'Gd', 'Au', 'Ag'],
          'correctAnswerIndex': 2,
        },
        {
          'id': 'q3',
          'questionText': 'What is the capital of India?',
          'options': ['Mumbai', 'Delhi', 'Kolkata', 'Chennai'],
          'correctAnswerIndex': 1,
        },
        {
          'id': 'q4',
          'questionText': 'Who wrote "Romeo and Juliet"?',
          'options': ['Charles Dickens', 'William Shakespeare', 'Jane Austen', 'Mark Twain'],
          'correctAnswerIndex': 1,
        },
        {
          'id': 'q5',
          'questionText': 'What is 15 + 27?',
          'options': ['42', '40', '44', '38'],
          'correctAnswerIndex': 0,
        },
      ],
      'timeInMinutes': 30,
      'pointsRequired': 50,
      'status': 'approved',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    };
    
    _exams['exam2'] = {
      'id': 'exam2',
      'title': 'NEET UG 2025',
      'description': 'National Eligibility cum Entrance Test',
      'type': 'entrance_exam',
      'category': 'Medical',
      'questions': [
        {
          'id': 'q1',
          'questionText': 'What is the powerhouse of the cell?',
          'options': ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi body'],
          'correctAnswerIndex': 1,
        },
        {
          'id': 'q2',
          'questionText': 'What is H2O?',
          'options': ['Hydrogen', 'Oxygen', 'Water', 'Carbon dioxide'],
          'correctAnswerIndex': 2,
        },
        {
          'id': 'q3',
          'questionText': 'How many bones in adult human body?',
          'options': ['186', '206', '226', '256'],
          'correctAnswerIndex': 1,
        },
      ],
      'timeInMinutes': 45,
      'pointsRequired': 75,
      'status': 'approved',
      'createdAt': DateTime.now().subtract(const Duration(days: 20)),
    };

    _exams['exam3'] = {
      'id': 'exam3',
      'title': 'UPSC Prelims 2025',
      'description': 'Civil Services Preliminary Examination',
      'type': 'entrance_exam',
      'category': 'Civil Services',
      'questions': [
        {
          'id': 'q1',
          'questionText': 'Who is the current President of India?',
          'options': ['Ram Nath Kovind', 'Droupadi Murmu', 'Pranab Mukherjee', 'APJ Abdul Kalam'],
          'correctAnswerIndex': 1,
        },
        {
          'id': 'q2',
          'questionText': 'What is Article 370?',
          'options': ['Emergency', 'J&K Special Status', 'Fundamental Rights', 'Parliament Power'],
          'correctAnswerIndex': 1,
        },
      ],
      'timeInMinutes': 120,
      'pointsRequired': 100,
      'status': 'approved',
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
    };

    // Sample SME content
    _content['content1'] = {
      'id': 'content1',
      'title': 'Physics Mock Test - Chapter 1',
      'type': 'mock_test',
      'description': 'Complete mock test for physics chapter 1',
      'fileUrls': [],
      'uploadedBy': 'sme1',
      'status': 'approved',
      'uploadedAt': DateTime.now().subtract(const Duration(days: 5)),
      'approvedAt': DateTime.now().subtract(const Duration(days: 3)),
      'rewardGiven': true,
      'approvalRewardAmount': 500,
      'userCompletionCount': 156,
      'usageRewardGiven': true,
      'usageRewardAmount': 1560,
    };
    
    _content['content2'] = {
      'id': 'content2',
      'title': 'Chemistry Notes - Organic',
      'type': 'study_notes',
      'description': 'Complete organic chemistry notes',
      'fileUrls': [],
      'uploadedBy': 'sme1',
      'status': 'pending',
      'uploadedAt': DateTime.now().subtract(const Duration(days: 2)),
      'rewardGiven': false,
      'approvalRewardAmount': 0,
      'userCompletionCount': 0,
      'usageRewardGiven': false,
      'usageRewardAmount': 0,
    };

    // SME Wallet
    _smeWallets['sme1'] = {
      'id': 'sme1',
      'totalEarnings': 2060,
      'availableBalance': 1560,
      'totalWithdrawn': 500,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      'lastUpdatedAt': DateTime.now(),
    };

    // Reward Transactions
    _rewardTransactions['tx1'] = {
      'id': 'tx1',
      'smeUid': 'sme1',
      'contentId': 'content1',
      'rewardType': 'approval',
      'amount': 500,
      'description': 'Reward for mock_test approval: Physics Mock Test',
      'status': 'completed',
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
    };
    
    _rewardTransactions['tx2'] = {
      'id': 'tx2',
      'smeUid': 'sme1',
      'contentId': 'content1',
      'rewardType': 'usage_threshold',
      'amount': 1560,
      'description': 'Usage reward (156 users): Physics Mock Test',
      'status': 'completed',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    };
  }

  // User operations
  Map<String, dynamic>? getUser(String uid) => _users[uid];
  
  Map<String, Map<String, dynamic>> get users => _users;
  
  Map<String, dynamic>? getUserByEmail(String email) {
    for (var user in _users.values) {
      if (user['email'] == email) return user;
    }
    return null;
  }
  
  void createUser(Map<String, dynamic> user) {
    _users[user['uid']] = user;
  }
  
  void updateUser(String uid, Map<String, dynamic> data) {
    if (_users.containsKey(uid)) {
      _users[uid]!.addAll(data);
    }
  }

  // Current user
  String? get currentUserId => _currentUserId;
  void setCurrentUser(String? uid) => _currentUserId = uid;
  Map<String, dynamic>? get currentUser => _currentUserId != null ? _users[_currentUserId] : null;

  // Exam operations
  List<Map<String, dynamic>> getExams({String? status}) {
    var exams = _exams.values.toList();
    if (status != null) {
      exams = exams.where((e) => e['status'] == status).toList();
    }
    return exams;
  }
  
  Map<String, dynamic>? getExam(String id) => _exams[id];

  // Content operations
  List<Map<String, dynamic>> getContent({String? uploadedBy, String? status}) {
    var content = _content.values.toList();
    if (uploadedBy != null) {
      content = content.where((c) => c['uploadedBy'] == uploadedBy).toList();
    }
    if (status != null) {
      content = content.where((c) => c['status'] == status).toList();
    }
    return content;
  }
  
  void addContent(Map<String, dynamic> content) {
    _content[content['id']] = content;
  }
  
  void updateContent(String id, Map<String, dynamic> data) {
    if (_content.containsKey(id)) {
      _content[id]!.addAll(data);
    }
  }

  // SME Wallet
  Map<String, dynamic>? getSMEWallet(String smeUid) => _smeWallets[smeUid];
  
  void updateSMEWallet(String smeUid, Map<String, dynamic> data) {
    if (_smeWallets.containsKey(smeUid)) {
      _smeWallets[smeUid]!.addAll(data);
    }
  }

  // Transactions
  List<Map<String, dynamic>> getRewardTransactions(String smeUid) {
    return _rewardTransactions.values
        .where((t) => t['smeUid'] == smeUid)
        .toList();
  }
  
  void addRewardTransaction(Map<String, dynamic> tx) {
    _rewardTransactions[tx['id']] = tx;
  }

  // Points transactions
  List<Map<String, dynamic>> getUserTransactions(String userId) {
    return _transactions.values
        .where((t) => t['userId'] == userId)
        .toList();
  }
  
  void addUserTransaction(Map<String, dynamic> tx) {
    _transactions[tx['id']] = tx;
  }
}

// Global instance
final localStorage = LocalStorage();