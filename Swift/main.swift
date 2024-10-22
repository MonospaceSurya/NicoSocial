```swift
import SwiftUI

struct Event: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let time: String
    let description: String
    let location: String
    let estimatedCost: String
    let socialFun: Int
    let imageUrl: String
    let date: Date
}

@main
struct EventsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            EventsTabsPage()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
                .tag(0)

            Text("Collections")
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Collections")
                }
                .tag(1)

            Text("Search")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(2)

            Text("Menu")
                .tabItem {
                    Image(systemName: "square.grid.4x3.fill")
                    Text("Menu")
                }
                .tag(3)
        }
        .accentColor(.orange)
    }
}

struct EventsTabsPage: View {
    @StateObject private var viewModel = EventsViewModel()

    var body: some View {
        NavigationView {
            TabView {
                SimpleMapView(events: viewModel.allEvents)
                    .tabItem {
                        Image(systemName: "map")
                    }

                CalendarView(events: viewModel.eventsByDate)
                    .tabItem {
                        Image(systemName: "calendar")
                    }

                EventsFeedPage(events: viewModel.allEvents)
                    .tabItem {
                        Image(systemName: "list.bullet")
                    }
            }
            .navigationTitle("Events")
            .navigationBarItems(trailing:
                NavigationLink(destination: ProfileView()) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                        .overlay(
                            AsyncImage(url: URL(string: "https://via.placeholder.com/40")) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .clipShape(Circle())
                            .padding(2)
                        )
                }
            )
        }
    }
}

class EventsViewModel: ObservableObject {
    @Published var allEvents: [Event] = []
    @Published var eventsByDate: [Date: [Event]] = [:]

    init() {
        setupSampleEvents()
    }

    private func setupSampleEvents() {
        allEvents = [
            Event(title: "Cevin Sephora",
                  time: "8:00 PM - 11:00 PM",
                  description: "Experience the captivating sounds of Cevin Sephora in a night filled with world music rhythms and melodies.",
                  location: "Central Park Stage",
                  estimatedCost: "$25",
                  socialFun: 4,
                  imageUrl: "https://via.placeholder.com/200x150",
                  date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()),
            Event(
                title: "Night Event",
                time: "9:00 PM - 1:00 AM",
                description:
                    "Dance the night away with electrifying live performances by renowned artists.",
                location: "The Venue",
                estimatedCost: "$35",
                socialFun: 5,
                imageUrl: "https://via.placeholder.com/200x150",
                date: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            ),
            Event(
                title: "Art Exhibition: Imaginary Worlds",
                time: "10:00 AM - 6:00 PM",
                description:
                    "Step into a world of imagination and creativity at the \"Imaginary Worlds\" art exhibition.",
                location: "City Art Gallery",
                estimatedCost: "$10",
                socialFun: 3,
                imageUrl: "https://via.placeholder.com/200x150",
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            ),
            Event(
                title: "Coding Bootcamp: Introduction to Python",
                time: "10:00 AM - 5:00 PM",
                description:
                    "Kickstart your coding journey with our immersive Python bootcamp.",
                location: "Tech Hub",
                estimatedCost: "$40",
                socialFun: 4,
                imageUrl: "https://via.placeholder.com/200x150",
                date: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date()
            ),
            Event(
                title: "Stand-up Comedy Night",
                time: "8:00 PM - 10:00 PM",
                description:
                    "Get ready for a night of laughter at our Stand-up Comedy Night.",
                location: "The Comedy Club",
                estimatedCost: "$20",
                socialFun: 5,
                imageUrl: "https://via.placeholder.com/200x150",
                date: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
            ),
            Event(
                title: "Board Game Extravaganza",
                time: "2:00 PM - 6:00 PM",
                description:
                    "Join us for an afternoon of board game fun.",
                location: "The Board Room",
                estimatedCost: "$5",
                socialFun: 4,
                imageUrl: "https://via.placeholder.com/200x150",
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            )
        ]

        eventsByDate = Dictionary(grouping: allEvents) { event in
            Calendar.current.startOfDay(for: event.date)
        }
    }
}

struct SimpleMapView: View {
    let events: [Event]

    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: "https://via.placeholder.com/800x600/1a1a1a/333333?text=Map")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .ignoresSafeArea()

            ForEach(events) { event in
                NavigationLink(destination: EventDetailsView(event: event)) {
                    VStack {
                        Text(event.title)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(12)

                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 32))
                    }
                }
                .position(x: UIScreen.main.bounds.width / 2,
                         y: UIScreen.main.bounds.height / 2)
            }
        }
    }
}

struct EventsFeedPage: View {
    let events: [Event]
    @State private var sortOption: SortOption = .date
    @State private var displayedEvents: [Event] = []

    enum SortOption: String, CaseIterable, Identifiable {
        case date = "Date"
        case cost = "Cost"
        case funScore = "Fun Score"

        var id: String { self.rawValue }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(displayedEvents) { event in
                    NavigationLink(destination: EventDetailsView(event: event)) {
                        EventCard(event: event)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Events")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
        .onAppear {
            displayedEvents = events
            sortEvents()
        }
        .onChange(of: sortOption) {
            sortEvents()
        }
    }

    private func sortEvents() {
        switch sortOption {
        case .date:
            displayedEvents.sort { $0.date < $1.date }
        case .cost:
            displayedEvents.sort {
                let cost1 = Int($0.estimatedCost.filter { $0.isNumber }) ?? 0
                let cost2 = Int($1.estimatedCost.filter { $0.isNumber }) ?? 0
                return cost1 < cost2
            }
        case .funScore:
            displayedEvents.sort { $0.socialFun < $1.socialFun }
        }
    }
}

struct EventCard: View {
    let event: Event

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack {
                HStack {
                    UserAvatars()
                    Spacer()
                    DateView(date: event.date)
                }

                Spacer()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(event

.time)
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .frame(height: 180)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct EventDetailsView: View {
    let event: Event

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: event.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 250)
                .clipped()

                Text(event.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(event.description)
                    .font(.body)
                    .foregroundColor(.gray)

                Text("Location: \(event.location)")
                    .font(.headline)

                Text("Estimated Cost: \(event.estimatedCost)")
                    .font(.headline)

                Text("Fun Score: \(event.socialFun)/5")
                    .font(.headline)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Event Details")
    }
}
```