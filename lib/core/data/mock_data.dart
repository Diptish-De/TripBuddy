
import 'package:uuid/uuid.dart';
import '../../features/auth/domain/user_entity.dart';
import '../../features/trips/domain/trip_entity.dart';
import '../../features/itinerary/domain/itinerary_item_entity.dart';
import '../../features/expenses/domain/expense_entity.dart';
import '../../features/packing/domain/packing_item_entity.dart';
import '../../features/notes/domain/note_entity.dart';
import '../../features/voting/domain/poll_entity.dart';
import '../../features/chat/domain/message_entity.dart';

const _uuid = Uuid();

/// Mock data service providing realistic demo data for all features.
/// Will be replaced with Supabase when backend is connected.
class MockData {
  MockData._();

  // ── Current User ──
  static final currentUser = UserEntity(
    id: 'user-1',
    displayName: 'Diptish',
    email: 'diptish@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  // ── Other Users ──
  static final users = [
    currentUser,
    UserEntity(
      id: 'user-2',
      displayName: 'Arjun Mehta',
      email: 'arjun@example.com',
      createdAt: DateTime(2024, 2, 15),
    ),
    UserEntity(
      id: 'user-3',
      displayName: 'Priya Sharma',
      email: 'priya@example.com',
      createdAt: DateTime(2024, 3, 10),
    ),
    UserEntity(
      id: 'user-4',
      displayName: 'Rahul Singh',
      email: 'rahul@example.com',
      createdAt: DateTime(2024, 4, 5),
    ),
    UserEntity(
      id: 'user-5',
      displayName: 'Sneha Patel',
      email: 'sneha@example.com',
      createdAt: DateTime(2024, 5, 20),
    ),
    UserEntity(
      id: 'user-6',
      displayName: 'Vikram Das',
      email: 'vikram@example.com',
      createdAt: DateTime(2024, 6, 12),
    ),
  ];

  static final Map<String, String> userNames = {
    for (final u in users) u.id: u.displayName,
  };

  // ── Trips ──
  static final trips = [
    TripEntity(
      id: 'trip-1',
      name: 'Darjeeling Adventure',
      description: 'A week in the hills with the squad! Tea gardens, toy train, sunrise at Tiger Hill.',
      destination: 'Darjeeling, West Bengal',
      coverImageUrl: 'https://images.unsplash.com/photo-1622308644420-76fbb9a0d4a6?w=800',
      startDate: DateTime.now().add(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 21)),
      inviteCode: 'DJG24X',
      createdBy: 'user-1',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      members: [
        TripMemberEntity(id: 'm1', tripId: 'trip-1', userId: 'user-1', role: 'admin', joinedAt: DateTime.now().subtract(const Duration(days: 5)), user: users[0]),
        TripMemberEntity(id: 'm2', tripId: 'trip-1', userId: 'user-2', role: 'member', joinedAt: DateTime.now().subtract(const Duration(days: 4)), user: users[1]),
        TripMemberEntity(id: 'm3', tripId: 'trip-1', userId: 'user-3', role: 'member', joinedAt: DateTime.now().subtract(const Duration(days: 3)), user: users[2]),
        TripMemberEntity(id: 'm4', tripId: 'trip-1', userId: 'user-4', role: 'member', joinedAt: DateTime.now().subtract(const Duration(days: 3)), user: users[3]),
        TripMemberEntity(id: 'm5', tripId: 'trip-1', userId: 'user-5', role: 'member', joinedAt: DateTime.now().subtract(const Duration(days: 2)), user: users[4]),
        TripMemberEntity(id: 'm6', tripId: 'trip-1', userId: 'user-6', role: 'member', joinedAt: DateTime.now().subtract(const Duration(days: 1)), user: users[5]),
      ],
    ),
    TripEntity(
      id: 'trip-2',
      name: 'Goa Beach Vibes',
      description: 'Sun, sand, and good times!',
      destination: 'Goa',
      coverImageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800',
      startDate: DateTime.now().add(const Duration(days: 45)),
      endDate: DateTime.now().add(const Duration(days: 49)),
      inviteCode: 'GOA4FN',
      createdBy: 'user-2',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      members: [
        TripMemberEntity(id: 'm7', tripId: 'trip-2', userId: 'user-2', role: 'admin', joinedAt: DateTime.now().subtract(const Duration(days: 2)), user: users[1]),
        TripMemberEntity(id: 'm8', tripId: 'trip-2', userId: 'user-1', role: 'member', joinedAt: DateTime.now().subtract(const Duration(days: 1)), user: users[0]),
        TripMemberEntity(id: 'm9', tripId: 'trip-2', userId: 'user-3', role: 'member', joinedAt: DateTime.now(), user: users[2]),
      ],
    ),
    TripEntity(
      id: 'trip-3',
      name: 'Manali Backpacking',
      description: 'Mountains are calling and we must go!',
      destination: 'Manali, Himachal Pradesh',
      coverImageUrl: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 5)),
      inviteCode: 'MNL3BK',
      createdBy: 'user-1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      members: [
        TripMemberEntity(id: 'm10', tripId: 'trip-3', userId: 'user-1', role: 'admin', joinedAt: DateTime.now().subtract(const Duration(days: 30)), user: users[0]),
        TripMemberEntity(id: 'm11', tripId: 'trip-3', userId: 'user-4', role: 'member', joinedAt: DateTime.now().subtract(const Duration(days: 28)), user: users[3]),
        TripMemberEntity(id: 'm12', tripId: 'trip-3', userId: 'user-5', role: 'member', joinedAt: DateTime.now().subtract(const Duration(days: 27)), user: users[4]),
      ],
    ),
  ];

  // ── Itinerary for Darjeeling trip ──
  static List<ItineraryItemEntity> getItinerary(String tripId) {
    if (tripId != 'trip-1') return [];
    final start = trips[0].startDate;
    return [
      ItineraryItemEntity(id: 'it-1', tripId: tripId, title: 'Train to NJP', description: 'Rajdhani Express from Howrah', location: 'Howrah Station', date: start, startTime: DateTime(2024, 1, 1, 6, 30), endTime: DateTime(2024, 1, 1, 14, 0), category: 'transport', addedBy: 'user-1', sortOrder: 0, createdAt: DateTime.now()),
      ItineraryItemEntity(id: 'it-2', tripId: tripId, title: 'Jeep to Darjeeling', description: 'Shared jeep from NJP to Darjeeling', location: 'NJP Station', date: start, startTime: DateTime(2024, 1, 1, 15, 0), endTime: DateTime(2024, 1, 1, 18, 0), category: 'transport', addedBy: 'user-2', sortOrder: 1, createdAt: DateTime.now()),
      ItineraryItemEntity(id: 'it-3', tripId: tripId, title: 'Check-in at Hotel', description: 'Hotel Pine Ridge, Mall Road', location: 'Mall Road, Darjeeling', date: start, startTime: DateTime(2024, 1, 1, 18, 30), category: 'stay', addedBy: 'user-1', sortOrder: 2, createdAt: DateTime.now()),
      ItineraryItemEntity(id: 'it-4', tripId: tripId, title: 'Dinner at Glenary\'s', description: 'Best restaurant in town!', location: 'Glenary\'s, Nehru Road', date: start, startTime: DateTime(2024, 1, 1, 20, 0), category: 'food', addedBy: 'user-3', sortOrder: 3, createdAt: DateTime.now()),
      ItineraryItemEntity(id: 'it-5', tripId: tripId, title: 'Tiger Hill Sunrise', description: 'Wake up early for the iconic sunrise over Kanchenjunga!', location: 'Tiger Hill', date: start.add(const Duration(days: 1)), startTime: DateTime(2024, 1, 1, 4, 0), endTime: DateTime(2024, 1, 1, 7, 0), category: 'activity', addedBy: 'user-1', sortOrder: 4, createdAt: DateTime.now()),
      ItineraryItemEntity(id: 'it-6', tripId: tripId, title: 'Batasia Loop & War Memorial', description: 'Beautiful garden with toy train loop', location: 'Batasia Loop', date: start.add(const Duration(days: 1)), startTime: DateTime(2024, 1, 1, 9, 0), endTime: DateTime(2024, 1, 1, 11, 0), category: 'activity', addedBy: 'user-4', sortOrder: 5, createdAt: DateTime.now()),
      ItineraryItemEntity(id: 'it-7', tripId: tripId, title: 'Tea Garden Visit', description: 'Happy Valley Tea Estate tour & tasting', location: 'Happy Valley', date: start.add(const Duration(days: 1)), startTime: DateTime(2024, 1, 1, 14, 0), endTime: DateTime(2024, 1, 1, 16, 0), category: 'activity', addedBy: 'user-5', sortOrder: 6, createdAt: DateTime.now()),
      ItineraryItemEntity(id: 'it-8', tripId: tripId, title: 'Mall Road Shopping', description: 'Pick up souvenirs and warm clothes', location: 'Mall Road', date: start.add(const Duration(days: 2)), startTime: DateTime(2024, 1, 1, 10, 0), endTime: DateTime(2024, 1, 1, 13, 0), category: 'activity', addedBy: 'user-3', sortOrder: 7, createdAt: DateTime.now()),
      ItineraryItemEntity(id: 'it-9', tripId: tripId, title: 'Toy Train Ride', description: 'Darjeeling Himalayan Railway joy ride', location: 'Darjeeling Station', date: start.add(const Duration(days: 2)), startTime: DateTime(2024, 1, 1, 15, 0), endTime: DateTime(2024, 1, 1, 17, 0), category: 'activity', addedBy: 'user-6', sortOrder: 8, createdAt: DateTime.now()),
    ];
  }

  // ── Expenses for Darjeeling trip ──
  static List<ExpenseEntity> getExpenses(String tripId) {
    if (tripId != 'trip-1') return [];
    final memberIds = ['user-1', 'user-2', 'user-3', 'user-4', 'user-5', 'user-6'];
    return [
      _makeExpense('exp-1', tripId, 'user-1', 'Diptish', 'Train Tickets', 8400, 'transport', memberIds, -1),
      _makeExpense('exp-2', tripId, 'user-2', 'Arjun Mehta', 'Jeep to Darjeeling', 4200, 'transport', memberIds, -2),
      _makeExpense('exp-3', tripId, 'user-3', 'Priya Sharma', 'Hotel Booking (3 nights)', 18000, 'stay', memberIds, -3),
      _makeExpense('exp-4', tripId, 'user-1', 'Diptish', 'Dinner at Glenary\'s', 3600, 'food', memberIds, -1),
      _makeExpense('exp-5', tripId, 'user-4', 'Rahul Singh', 'Tiger Hill Jeep', 2400, 'transport', memberIds, -2),
      _makeExpense('exp-6', tripId, 'user-5', 'Sneha Patel', 'Lunch at Keventer\'s', 2100, 'food', memberIds, -1),
      _makeExpense('exp-7', tripId, 'user-6', 'Vikram Das', 'Tea Garden Entry', 600, 'activity', memberIds, -4),
      _makeExpense('exp-8', tripId, 'user-2', 'Arjun Mehta', 'Toy Train Tickets', 3000, 'activity', memberIds, -3),
    ];
  }

  static ExpenseEntity _makeExpense(String id, String tripId, String paidBy, String paidByName, String title, double amount, String category, List<String> memberIds, int daysAgo) {
    final splitAmount = amount / memberIds.length;
    return ExpenseEntity(
      id: id,
      tripId: tripId,
      paidBy: paidBy,
      paidByName: paidByName,
      title: title,
      amount: amount,
      category: category,
      splits: memberIds.map((uid) => ExpenseSplitEntity(
        id: _uuid.v4(),
        expenseId: id,
        userId: uid,
        userName: userNames[uid] ?? '',
        amount: double.parse(splitAmount.toStringAsFixed(2)),
      )).toList(),
      createdAt: DateTime.now().add(Duration(days: daysAgo)),
    );
  }

  // ── Packing Items ──
  static List<PackingItemEntity> getPackingItems(String tripId) {
    if (tripId != 'trip-1') return [];
    return [
      PackingItemEntity(id: 'pk-1', tripId: tripId, itemName: 'Warm Jacket', category: 'clothing', assignedTo: null, isPacked: true, addedBy: 'user-1', createdAt: DateTime.now()),
      PackingItemEntity(id: 'pk-2', tripId: tripId, itemName: 'Thermal Wear', category: 'clothing', assignedTo: null, isPacked: false, addedBy: 'user-1', createdAt: DateTime.now()),
      PackingItemEntity(id: 'pk-3', tripId: tripId, itemName: 'Rain Poncho', category: 'clothing', assignedTo: 'user-3', assignedToName: 'Priya Sharma', isPacked: false, addedBy: 'user-3', createdAt: DateTime.now()),
      PackingItemEntity(id: 'pk-4', tripId: tripId, itemName: 'Sunscreen SPF 50', category: 'toiletries', assignedTo: 'user-5', assignedToName: 'Sneha Patel', isPacked: true, addedBy: 'user-5', createdAt: DateTime.now()),
      PackingItemEntity(id: 'pk-5', tripId: tripId, itemName: 'Power Bank', category: 'electronics', assignedTo: 'user-2', assignedToName: 'Arjun Mehta', isPacked: false, addedBy: 'user-2', createdAt: DateTime.now()),
      PackingItemEntity(id: 'pk-6', tripId: tripId, itemName: 'Camera + Tripod', category: 'electronics', assignedTo: 'user-6', assignedToName: 'Vikram Das', isPacked: true, addedBy: 'user-6', createdAt: DateTime.now()),
      PackingItemEntity(id: 'pk-7', tripId: tripId, itemName: 'ID Proofs (Aadhar/PAN)', category: 'documents', assignedTo: null, isPacked: false, addedBy: 'user-1', createdAt: DateTime.now()),
      PackingItemEntity(id: 'pk-8', tripId: tripId, itemName: 'First Aid Kit', category: 'medicine', assignedTo: 'user-4', assignedToName: 'Rahul Singh', isPacked: false, addedBy: 'user-4', createdAt: DateTime.now()),
      PackingItemEntity(id: 'pk-9', tripId: tripId, itemName: 'Hiking Shoes', category: 'clothing', assignedTo: null, isPacked: false, addedBy: 'user-1', createdAt: DateTime.now()),
      PackingItemEntity(id: 'pk-10', tripId: tripId, itemName: 'Snacks & Biscuits', category: 'food', assignedTo: 'user-5', assignedToName: 'Sneha Patel', isPacked: false, addedBy: 'user-5', createdAt: DateTime.now()),
    ];
  }

  // ── Notes ──
  static List<NoteEntity> getNotes(String tripId) {
    if (tripId != 'trip-1') return [];
    return [
      NoteEntity(id: 'note-1', tripId: tripId, title: '📌 Hotel Booking Details', content: 'Hotel Pine Ridge, Mall Road\nBooking ID: HTL-2024-8834\nCheck-in: 2 PM\nCheck-out: 11 AM\nWiFi Password: pinridge2024\n\n3 rooms booked (2 sharing each)', isPinned: true, addedBy: 'user-3', addedByName: 'Priya Sharma', createdAt: DateTime.now().subtract(const Duration(days: 3)), updatedAt: DateTime.now().subtract(const Duration(days: 3))),
      NoteEntity(id: 'note-2', tripId: tripId, title: '🚂 Train Details', content: 'Rajdhani Express (12301)\nHowrah → NJP\nPNR: 4521-7789-3344\nCoach: B2, Seats: 21-26\nDeparture: 6:30 AM', isPinned: true, addedBy: 'user-1', addedByName: 'Diptish', createdAt: DateTime.now().subtract(const Duration(days: 4)), updatedAt: DateTime.now().subtract(const Duration(days: 4))),
      NoteEntity(id: 'note-3', tripId: tripId, title: '📞 Emergency Contacts', content: 'Hotel: +91 354-225-4078\nLocal Guide (Tenzing): +91 98320-45672\nNearest Hospital: Planters Hospital, +91 354-225-7200', isPinned: false, addedBy: 'user-1', addedByName: 'Diptish', createdAt: DateTime.now().subtract(const Duration(days: 2)), updatedAt: DateTime.now().subtract(const Duration(days: 2))),
      NoteEntity(id: 'note-4', tripId: tripId, title: '🍽️ Must-Try Food Places', content: '1. Glenary\'s - Continental & Bakery\n2. Keventer\'s - Breakfast & Snacks\n3. Kunga\'s - Tibetan Food\n4. Sonam\'s Kitchen - Momos\n5. Gatty\'s Cafe - Coffee & Desserts', isPinned: false, addedBy: 'user-5', addedByName: 'Sneha Patel', createdAt: DateTime.now().subtract(const Duration(days: 1)), updatedAt: DateTime.now().subtract(const Duration(days: 1))),
    ];
  }

  // ── Polls ──
  static List<PollEntity> getPolls(String tripId) {
    if (tripId != 'trip-1') return [];
    return [
      PollEntity(
        id: 'poll-1',
        tripId: tripId,
        question: 'Should we do river rafting at Teesta?',
        isActive: true,
        createdBy: 'user-2',
        createdByName: 'Arjun Mehta',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        options: [
          PollOptionEntity(id: 'po-1', pollId: 'poll-1', optionText: 'Yes, definitely! 🏄', sortOrder: 0, votes: [
            PollVoteEntity(id: 'pv-1', optionId: 'po-1', userId: 'user-1', userName: 'Diptish'),
            PollVoteEntity(id: 'pv-2', optionId: 'po-1', userId: 'user-2', userName: 'Arjun Mehta'),
            PollVoteEntity(id: 'pv-3', optionId: 'po-1', userId: 'user-6', userName: 'Vikram Das'),
          ]),
          PollOptionEntity(id: 'po-2', pollId: 'poll-1', optionText: 'Maybe, depends on weather', sortOrder: 1, votes: [
            PollVoteEntity(id: 'pv-4', optionId: 'po-2', userId: 'user-3', userName: 'Priya Sharma'),
          ]),
          PollOptionEntity(id: 'po-3', pollId: 'poll-1', optionText: 'No, too risky 😅', sortOrder: 2, votes: [
            PollVoteEntity(id: 'pv-5', optionId: 'po-3', userId: 'user-4', userName: 'Rahul Singh'),
          ]),
        ],
      ),
      PollEntity(
        id: 'poll-2',
        tripId: tripId,
        question: 'What cuisine for Day 2 dinner?',
        isActive: true,
        createdBy: 'user-5',
        createdByName: 'Sneha Patel',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        options: [
          PollOptionEntity(id: 'po-4', pollId: 'poll-2', optionText: 'Tibetan 🥟', sortOrder: 0, votes: [
            PollVoteEntity(id: 'pv-6', optionId: 'po-4', userId: 'user-1', userName: 'Diptish'),
            PollVoteEntity(id: 'pv-7', optionId: 'po-4', userId: 'user-5', userName: 'Sneha Patel'),
          ]),
          PollOptionEntity(id: 'po-5', pollId: 'poll-2', optionText: 'Indian / Bengali', sortOrder: 1, votes: [
            PollVoteEntity(id: 'pv-8', optionId: 'po-5', userId: 'user-3', userName: 'Priya Sharma'),
            PollVoteEntity(id: 'pv-9', optionId: 'po-5', userId: 'user-4', userName: 'Rahul Singh'),
          ]),
          PollOptionEntity(id: 'po-6', pollId: 'poll-2', optionText: 'Continental', sortOrder: 2, votes: []),
        ],
      ),
    ];
  }

  // ── Chat Messages ──
  static List<MessageEntity> getMessages(String tripId) {
    if (tripId != 'trip-1') return [];
    final now = DateTime.now();
    return [
      MessageEntity(id: 'msg-1', tripId: tripId, userId: 'system', userName: 'TripBuddy', content: 'Diptish created "Darjeeling Adventure" 🎉', messageType: 'system', createdAt: now.subtract(const Duration(days: 5))),
      MessageEntity(id: 'msg-2', tripId: tripId, userId: 'user-2', userName: 'Arjun Mehta', content: 'Let\'s gooo! 🏔️ This is going to be epic!', createdAt: now.subtract(const Duration(days: 4, hours: 22))),
      MessageEntity(id: 'msg-3', tripId: tripId, userId: 'user-3', userName: 'Priya Sharma', content: 'I\'ve booked the hotel, check the notes section for details!', createdAt: now.subtract(const Duration(days: 4, hours: 20))),
      MessageEntity(id: 'msg-4', tripId: tripId, userId: 'user-1', userName: 'Diptish', content: 'Amazing! Thanks Priya. I\'ll handle the train tickets.', createdAt: now.subtract(const Duration(days: 4, hours: 19))),
      MessageEntity(id: 'msg-5', tripId: tripId, userId: 'user-5', userName: 'Sneha Patel', content: 'Should I bring the DSLR or will phone cameras be enough?', createdAt: now.subtract(const Duration(days: 3, hours: 10))),
      MessageEntity(id: 'msg-6', tripId: tripId, userId: 'user-6', userName: 'Vikram Das', content: 'I\'m bringing my camera and tripod, don\'t worry! 📸', createdAt: now.subtract(const Duration(days: 3, hours: 9))),
      MessageEntity(id: 'msg-7', tripId: tripId, userId: 'user-4', userName: 'Rahul Singh', content: 'Guys pack warm. It\'s going to be around 5-8°C there 🥶', createdAt: now.subtract(const Duration(days: 2, hours: 5))),
      MessageEntity(id: 'msg-8', tripId: tripId, userId: 'user-1', userName: 'Diptish', content: 'Added Tiger Hill sunrise to the itinerary. Wake up call at 3:30 AM! 😤', createdAt: now.subtract(const Duration(days: 1, hours: 3))),
      MessageEntity(id: 'msg-9', tripId: tripId, userId: 'user-2', userName: 'Arjun Mehta', content: '3:30 AM?! 😱 Okay fine, it better be worth it', createdAt: now.subtract(const Duration(days: 1, hours: 2))),
      MessageEntity(id: 'msg-10', tripId: tripId, userId: 'user-3', userName: 'Priya Sharma', content: 'Trust me, it\'s magical. The Kanchenjunga sunrise is unforgettable! ✨', createdAt: now.subtract(const Duration(hours: 23))),
      MessageEntity(id: 'msg-11', tripId: tripId, userId: 'user-5', userName: 'Sneha Patel', content: 'Vote on the dinner poll btw! I added it just now 🍽️', createdAt: now.subtract(const Duration(hours: 6))),
    ];
  }
}
