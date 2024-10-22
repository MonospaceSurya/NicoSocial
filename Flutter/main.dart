import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const EventsApp());
}

class EventsApp extends StatelessWidget {
  const EventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Events App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.deepOrange,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.black.withOpacity(0.8),
          indicatorColor: Colors.grey.withOpacity(0.2),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          EventsTabsPage(),
          Center(child: Text('Collections')),
          Center(child: Text('Search')),
          Center(child: Text('Menu')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 65,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today, size: 22),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections, size: 22),
            label: 'Collections',
          ),
          NavigationDestination(
            icon: Icon(Icons.search, size: 22),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_4x4, size: 22),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}

class EventsTabsPage extends StatefulWidget {
  const EventsTabsPage({super.key});

  @override
  State<EventsTabsPage> createState() => _EventsTabsPageState();
}

class _EventsTabsPageState extends State<EventsTabsPage> {
  List<Event> allEvents = [
    Event(
        title: 'Cevin Sephora',
        time: '8:00 PM - 11:00 PM',
        description:
            'Experience the captivating sounds of Cevin Sephora in a night filled with world music rhythms and melodies. ',
        location: 'Central Park Stage',
        estimatedCost: '\$25',
        socialFun: 4,
        imageUrl: 'assets/night.png',
        date: DateTime.now().add(const Duration(days: 2))),
    Event(
        title: 'Night Event',
        time: '9:00 PM - 1:00 AM',
        description:
            'Dance the night away with electrifying live performances by renowned artists. Get ready for an unforgettable night of music, lights, and entertainment!',
        location: 'The Venue',
        estimatedCost: '\$35',
        socialFun: 5,
        imageUrl: 'assets/night.png',
        date: DateTime.now().add(const Duration(days: 7))),
    Event(
        title: 'Art Exhibition: Imaginary Worlds',
        time: '10:00 AM - 6:00 PM',
        description:
            'Step into a world of imagination and creativity at the "Imaginary Worlds" art exhibition. Featuring a diverse collection of paintings, sculptures, and digital art, this exhibition promises to be a feast for the senses.',
        location: 'City Art Gallery',
        estimatedCost: '\$10',
        socialFun: 3,
        imageUrl: 'assets/night.png',
        date: DateTime.now().add(const Duration(days: 1))),
    Event(
        title: 'Coding Bootcamp: Introduction to Python',
        time: '10:00 AM - 5:00 PM',
        description:
            'Kickstart your coding journey with our immersive Python bootcamp. Designed for beginners, this workshop will provide you with the fundamentals of programming using Python.',
        location: 'Tech Hub',
        estimatedCost: '\$40',
        socialFun: 4,
        imageUrl: 'assets/night.png',
        date: DateTime.now().add(const Duration(days: 15))),
    Event(
        title: 'Stand-up Comedy Night',
        time: '8:00 PM - 10:00 PM',
        description:
            'Get ready for a night of laughter at our Stand-up Comedy Night. Featuring a lineup of hilarious comedians, this event is guaranteed to tickle your funny bone.',
        location: 'The Comedy Club',
        estimatedCost: '\$20',
        socialFun: 5,
        imageUrl: 'assets/night.png',
        date: DateTime.now().add(const Duration(days: 5))),
    Event(
        title: 'Board Game Extravaganza',
        time: '2:00 PM - 6:00 PM',
        description:
            'Calling all board game enthusiasts! Join us for an afternoon of board game fun. Bring your own games or choose from our extensive library.',
        location: 'The Board Room',
        estimatedCost: '\$5',
        socialFun: 4,
        imageUrl: 'assets/night.png',
        date: DateTime.now().add(const Duration(days: 1))),
    // Add more events here
  ];

  late Map<DateTime, List<Event>> _events;
  DateTime _selectedDate = DateTime.now();
  bool _showEventList = false;

  @override
  void initState() {
    super.initState();
    _events = _groupEventsByDate(allEvents);
  }

  Map<DateTime, List<Event>> _groupEventsByDate(List<Event> events) {
    Map<DateTime, List<Event>> groupedEvents = {};
    for (Event event in events) {
      DateTime date = DateTime(event.date.year, event.date.month, event.date.day);
      if (groupedEvents.containsKey(date)) {
        groupedEvents[date]!.add(event);
      } else {
        groupedEvents[date] = [event];
      }
    }
    return groupedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Events',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/40',
                  ),
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.map)),
              Tab(icon: Icon(Icons.calendar_today)),
              Tab(icon: Icon(Icons.view_list)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SimpleMapView(events: allEvents),
            Column(
              children: [
                CalendarPage(
                  events: _events,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      _showEventList = true;
                    });
                  },
                ),
                if (_showEventList)
                  Expanded(
                    child: EventList(events: _events[_selectedDate] ?? []),
                  ),
              ],
            ),
            EventsFeedPage(events: allEvents),
          ],
        ),
      ),
    );
  }
}

class EventLocation {
  final Offset position;
  final String title;
  final String description;
  final String date;
  final Event event;

  EventLocation({
    required this.position,
    required this.title,
    required this.description,
    required this.date,
    required this.event,
  });
}

class SimpleMapView extends StatelessWidget {
  final List<Event> events;
  const SimpleMapView({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Simple map background
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            image: const DecorationImage(
              image: NetworkImage(
                'https://via.placeholder.com/800x600/1a1a1a/333333?text=Map',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Event markers
        ...events.map((event) => Positioned(
              left: 0.5 * MediaQuery.of(context).size.width,
              top: 0.5 * MediaQuery.of(context).size.height,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsPage(event: event),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_on,
                      color: Colors.deepOrange,
                      size: 32,
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class EventsFeedPage extends StatefulWidget {
  final List<Event> events;
  const EventsFeedPage({Key? key, required this.events}) : super(key: key);

  @override
  State<EventsFeedPage> createState() => _EventsFeedPageState();
}

class _EventsFeedPageState extends State<EventsFeedPage> {
  String _selectedSortOption = 'Date';
  List<Event> displayedEvents = [];

  @override
  void initState() {
    displayedEvents = List.from(widget.events);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text(
              'Events',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/40',
                    ),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (String item) {
                  setState(() {
                    _selectedSortOption = item;
                    _sortEvents(item);
                  });
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'Date',
                      child: Text('Sort by Date'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Cost',
                      child: Text('Sort by Cost'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Fun Score',
                      child: Text('Sort by Fun Score'),
                    ),
                  ];
                },
                icon: const Icon(Icons.sort),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to event details page when the card is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EventDetailsPage(event: displayedEvents[index]),
                        ),
                      );
                    },
                    child: _buildEventCard(
                      title: displayedEvents[index].title,
                      subtitle: displayedEvents[index].location,
                      date: DateFormat('dd\nMMM').format(displayedEvents[index].date),
                      colors: const [Color(0xFFFF4500), Color(0xFFFF8C00)],
                      imageUrl: displayedEvents[index].imageUrl,
                    ),
                  );
                },
                childCount: displayedEvents.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required String subtitle,
    required String date,
    required List<Color> colors,
    required String imageUrl,
  }) {
    return Container(
      height: 240,
      margin: const EdgeInsets.only(bottom: 16), // Add margin here
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildUserAvatars(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        date,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatars() {
    return SizedBox(
      width: 60,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[400],
            ),
          ),
          Positioned(
            left: 24,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sortEvents(String criteria) {
    switch (criteria) {
      case 'Cost':
        // Extract numeric value from estimatedCost and sort
        displayedEvents.sort((a, b) {
          final aCost =
              int.tryParse(a.estimatedCost.replaceAll(RegExp(r'[^\d]'), '')) ??
                  0;
          final bCost =
              int.tryParse(b.estimatedCost.replaceAll(RegExp(r'[^\d]'), '')) ??
                  0;
          return aCost.compareTo(bCost);
        });
        break;
      case 'Fun Score':
        displayedEvents.sort((a, b) => a.socialFun.compareTo(b.socialFun));
        break;
      default:
        // Sort by date (assuming events have a date property)
        displayedEvents.sort(
            (a, b) => a.date.compareTo(b.date));
        break;
    }
  }
}

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${event.time}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${event.location}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated Cost: ${event.estimatedCost}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  final Map<DateTime, List<Event>> events;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarPage({
    Key? key,
    required this.events,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CalendarWidget(
            events: widget.events,
            onDateSelected: widget.onDateSelected,
          ),
          // Expanded(
          //   child: EventList(events: widget.events[_selectedDate] ?? []),
          // ),
        ],
      ),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  final Map<DateTime, List<Event>> events;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarWidget({
    Key? key,
    required this.events,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year,
                        _selectedDate.month - 1);
                  });
                  widget.onDateSelected(_selectedDate);
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year,
                        _selectedDate.month + 1);
                  });
                  widget.onDateSelected(_selectedDate);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Text(
              day,
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _getDaysInMonth(_selectedDate.year,
                _selectedDate.month) +
                _getStartWeekday(_selectedDate.year, _selectedDate.month),
            itemBuilder: (context, index) {
              if (index <
                  _getStartWeekday(_selectedDate.year, _selectedDate.month)) {
                return const SizedBox();
              }
              final day = index -
                  _getStartWeekday(_selectedDate.year, _selectedDate.month) +
                  1;
              final date =
              DateTime(_selectedDate.year, _selectedDate.month, day);
              final hasEvents = widget.events.containsKey(date);
              final isSelected = _selectedDate.year == date.year &&
                  _selectedDate.month == date.month &&
                  _selectedDate.day == date.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  widget.onDateSelected(date);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : hasEvents
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : hasEvents
                              ? Theme.of(context).primaryColor
                              : null,
                          fontWeight:
                          hasEvents ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasEvents && !isSelected)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getStartWeekday(int year, int month) {
    return DateTime(year, month, 1).weekday;
  }
}

class EventList extends StatelessWidget {
  final List<Event> events;

  const EventList({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return events.isEmpty
        ? const Center(child: Text('No events for this day'))
        : ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsPage(event: event),
              ),
            );
          },
          child: Card(
            color: Colors.grey[800],
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: ListTile(
              title: Text(
                event.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${event.time} - ${event.estimatedCost}',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text('${event.socialFun}/5'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Event {
  final String title;
  final String time;
  final String description;
  final String location;
  final String estimatedCost;
  final int socialFun;
  final String imageUrl;
  final DateTime date;

  Event({
    required this.title,
    required this.time,
    required this.description,
    required this.location,
    required this.estimatedCost,
    required this.socialFun,
    required this.imageUrl,
    required this.date,
  });
}