//
//  ContentView.swift
//  OMS-NEXUS
//
//  Created by Cheyenne Beheshtian on 3/7/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var homePath: [Route] = []
    @State private var lecturesPath: [Route] = []
    @State private var resourcesPath: [Route] = []
    @State private var communityPath: [Route] = []
    @State private var accountPath: [Route] = []

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeScreen(navigate: navigate)
                    .navigationDestination(for: Route.self, destination: destinationView)
            }
            .tag(AppTab.home)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack(path: $lecturesPath) {
                LecturesScreen(navigate: navigate)
                    .navigationDestination(for: Route.self, destination: destinationView)
            }
            .tag(AppTab.lectures)
            .tabItem {
                Label("Lectures", systemImage: "text.below.photo.fill")
            }

            NavigationStack(path: $resourcesPath) {
                ResourcesScreen()
                    .navigationDestination(for: Route.self, destination: destinationView)
            }
            .tag(AppTab.resources)
            .tabItem {
                Label("Resources", systemImage: "rectangle.on.rectangle")
            }

            NavigationStack(path: $communityPath) {
                CommunityScreen()
                    .navigationDestination(for: Route.self, destination: destinationView)
            }
            .tag(AppTab.community)
            .tabItem {
                Label("Community", systemImage: "person.2.fill")
            }

            NavigationStack(path: $accountPath) {
                AccountScreen(navigate: navigate)
                    .navigationDestination(for: Route.self, destination: destinationView)
            }
            .tag(AppTab.account)
            .tabItem {
                Label("Account", systemImage: "person.crop.circle")
            }
        }
        .tint(.blue)
    }

    @ViewBuilder
    private func destinationView(_ route: Route) -> some View {
        switch route {
        case .basicSciences:
            BasicSciencesScreen(navigate: navigate)
        case .module(let module):
            ModuleDetailScreen(module: module, navigate: navigate)
        case .chapter(let module, let chapter, let index):
            ChapterDetailScreen(module: module, chapter: chapter, chapterIndex: index)
        case .news:
            NewsScreen()
        case .about:
            AboutScreen()
        case .login:
            LoginScreen()
        case .signup:
            SignupScreen()
        case .account:
            AccountScreen(navigate: navigate)
        case .resources:
            ResourcesScreen()
        case .community:
            CommunityScreen()
        case .anatomyHub:
            LectureCategoryScreen(category: OMSHubData.lectureCategories[1], navigate: navigate)
        case .surgeryHub:
            LectureCategoryScreen(category: OMSHubData.lectureCategories[2], navigate: navigate)
        case .pharmacologyHub:
            LectureCategoryScreen(category: OMSHubData.lectureCategories[3], navigate: navigate)
        }
    }

    private func navigate(_ route: Route) {
        let targetTab = tab(for: route)
        selectedTab = targetTab

        switch route {
        case .resources, .community, .account:
            return
        default:
            break
        }

        switch targetTab {
        case .home:
            homePath.append(route)
        case .lectures:
            lecturesPath.append(route)
        case .resources:
            resourcesPath.append(route)
        case .community:
            communityPath.append(route)
        case .account:
            accountPath.append(route)
        }
    }

    private func tab(for route: Route) -> AppTab {
        switch route {
        case .basicSciences, .module, .chapter, .anatomyHub, .surgeryHub, .pharmacologyHub:
            return .lectures
        case .resources:
            return .resources
        case .community:
            return .community
        case .account, .login, .signup:
            return .account
        case .news, .about:
            return .home
        }
    }
}

private let dashboardColumns = [
    GridItem(.adaptive(minimum: 320, maximum: 420), spacing: 16, alignment: .top)
]

private struct HomeScreen: View {
    let navigate: (Route) -> Void
    @State private var searchText = ""

    private var filteredFeaturePanels: [FeaturePanel] {
        OMSHubData.featurePanels.filter { panel in
            searchText.isEmpty || "\(panel.title) \(panel.description) \(panel.keywords)".localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredNewsItems: [NewsItem] {
        OMSHubData.newsItems.filter { item in
            searchText.isEmpty || "\(item.category) \(item.title)".localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredModules: [LearningModule] {
        OMSHubData.basicScienceModules.filter { module in
            searchText.isEmpty || "\(module.title) \(module.category.title)".localizedCaseInsensitiveContains(searchText)
        }
    }

    private var noMatches: Bool {
        !searchText.isEmpty && filteredFeaturePanels.isEmpty && filteredNewsItems.isEmpty && filteredModules.isEmpty
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                hero
                searchPanel
                featurePanelSection
                curriculumSection
                newsSection
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("OMS Nexus")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    navigate(.account)
                } label: {
                    Image(systemName: "person.crop.circle")
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("OMS Nexus")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("A centralized evidence-based hub for residents and surgeons. Facilitating clinical mastery through shared inquiry and advanced surgical principles.")
                        .font(.system(size: 19))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            Image("homepage")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

            Button {
                navigate(.basicSciences)
            } label: {
                Text("Enter the Curriculum")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var searchPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search OMSHUB...", text: $searchText)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            if noMatches {
                Text("No matching hub content found.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var featurePanelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Hub Highlights", subtitle: "Key areas from the OMSHUB homepage.")

            ForEach(filteredFeaturePanels) { panel in
                Button {
                    navigate(panel.route)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(panel.title)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text(panel.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        Text(panel.cta)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var curriculumSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Popular Modules", subtitle: "Live OMSHUB modules surfaced on the homepage.")

            ForEach(filteredModules.prefix(4)) { module in
                Button {
                    navigate(.module(module))
                } label: {
                    HStack(spacing: 14) {
                        Image(module.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 74, height: 74)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(module.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("\(module.lessons) lessons • \(Int(module.completion * 100))% complete")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            ProgressView(value: module.completion)
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            Button("View All Basic Sciences") {
                navigate(.basicSciences)
            }
            .font(.headline)
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var newsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "News", subtitle: "Events and updates from the OMSHUB home page.")

            ForEach(filteredNewsItems) { item in
                Button {
                    navigate(.news)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.category.uppercased())
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.blue)
                            Text(item.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct LecturesScreen: View {
    let navigate: (Route) -> Void
    @State private var query = ""
    @State private var activeFilter = "All"
    private let filters = ["All", "Popular", "New"]

    private var filteredCategories: [LectureCategory] {
        OMSHubData.lectureCategories.filter { category in
            let matchesQuery = query.isEmpty || "\(category.title) \(category.subtitle) \(category.keywords)".localizedCaseInsensitiveContains(query)
            let matchesFilter = activeFilter == "All" || category.keywords.localizedCaseInsensitiveContains(activeFilter)
            return matchesQuery && matchesFilter
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lectures")
                        .font(.system(size: 38, weight: .bold))
                    Text("Explore our lecture categories in maxillofacial surgery and medical education.")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search lectures...", text: $query)
                }
                .padding(16)
                .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filters, id: \.self) { filter in
                            Button {
                                activeFilter = filter
                            } label: {
                                Text(filter)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(activeFilter == filter ? .white : .primary)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(activeFilter == filter ? Color.black : Color.white, in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                ForEach(filteredCategories) { category in
                    Button {
                        navigate(category.route)
                    } label: {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(category.icon)
                                        .font(.system(size: 44))
                                    Text(category.title)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text(category.subtitle)
                                        .font(.body)
                                        .foregroundStyle(.white.opacity(0.88))
                                }
                                Spacer()
                            }

                            Text("View Topics")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(.white.opacity(0.18), in: Capsule())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background(
                            LinearGradient(colors: category.colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Lectures")
    }
}

private struct LectureCategoryScreen: View {
    let category: LectureCategory
    let navigate: (Route) -> Void
    @State private var selectedFilter: TopicFilter = .all
    @State private var searchText = ""

    private var modules: [LearningModule] {
        category.items.compactMap(\.module)
    }

    private var filteredModules: [LearningModule] {
        modules.filter { module in
            let matchesFilter = selectedFilter == .all || module.category == selectedFilter
            let matchesSearch = searchText.isEmpty || "\(module.title) \(module.subtitle)".localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }

    private var averageCompletionText: String {
        guard !filteredModules.isEmpty else { return "0%" }
        let average = filteredModules.map(\.completion).reduce(0, +) / Double(filteredModules.count)
        return "\(Int(average * 100))%"
    }

    var body: some View {
        ZStack {
            DashboardBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("HOME  ›  LECTURES  ›  \(category.title.uppercased())")
                            .font(.system(size: 13, weight: .semibold))
                            .tracking(1.3)
                            .foregroundStyle(.white.opacity(0.75))

                        Text(category.title)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                        Text(category.subtitle)
                            .font(.system(size: 17))
                            .foregroundStyle(.white.opacity(0.82))
                    }

                    HStack(spacing: 14) {
                        Button {
                            navigate(.community)
                        } label: {
                            Text("+ Start New Discussion")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(
                                    LinearGradient(colors: [Color(red: 0.08, green: 0.29, blue: 0.95), Color(red: 0.12, green: 0.55, blue: 0.98)], startPoint: .leading, endPoint: .trailing),
                                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                                )
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.white.opacity(0.55))
                            TextField("Search topics...", text: $searchText)
                                .foregroundStyle(.white)
                                .tint(.white)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 17)
                        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(TopicFilter.allCases) { filter in
                                Button {
                                    selectedFilter = filter
                                } label: {
                                    Text(filter.title)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white.opacity(selectedFilter == filter ? 0.98 : 0.78))
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .fill(selectedFilter == filter ? Color.blue.opacity(0.34) : Color.white.opacity(0.08))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    LazyVGrid(columns: dashboardColumns, spacing: 16) {
                        ForEach(filteredModules) { module in
                            Button {
                                navigate(.module(module))
                            } label: {
                                DashboardModuleCard(module: module)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    HStack {
                        StatBlock(label: "TOPICS", value: "\(filteredModules.count)")
                        Spacer()
                        StatBlock(label: "LESSONS", value: "\(filteredModules.map(\.lessons).reduce(0, +))+")
                        Spacer()
                        StatBlock(label: "AVG COMPLETION", value: averageCompletionText)
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 20)
                    .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .padding(22)
            }
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

private struct BasicSciencesScreen: View {
    let navigate: (Route) -> Void
    @State private var selectedFilter: TopicFilter = .all
    @State private var searchText = ""

    private var filteredModules: [LearningModule] {
        OMSHubData.basicScienceModules.filter { module in
            let matchesFilter = selectedFilter == .all || module.category == selectedFilter
            let matchesSearch = searchText.isEmpty || "\(module.title) \(module.subtitle)".localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }

    private var averageCompletionText: String {
        guard !filteredModules.isEmpty else { return "0%" }
        let average = filteredModules.map(\.completion).reduce(0, +) / Double(filteredModules.count)
        return "\(Int(average * 100))%"
    }

    var body: some View {
        ZStack {
            DashboardBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    heroSection
                    actionRow
                    filterRow
                    moduleGrid
                    statsStrip
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 34)
            }
        }
        .navigationTitle("Basic Sciences")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image("logo2")
                .resizable()
                .scaledToFit()
                .frame(width: 46, height: 46)
                .clipShape(Circle())

            Text("OMS Nexus")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color(red: 0.04, green: 0.08, blue: 0.22))

            Spacer()

            Image(systemName: "bell")
                .font(.system(size: 24))
                .foregroundStyle(Color(red: 0.15, green: 0.18, blue: 0.28))

            Image(systemName: "magnifyingglass")
                .font(.system(size: 25))
                .foregroundStyle(Color(red: 0.15, green: 0.18, blue: 0.28))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HOME  ›  LECTURES  ›  BASIC SCIENCES")
                .font(.system(size: 13, weight: .semibold))
                .tracking(1.3)
                .foregroundStyle(.white.opacity(0.75))

            Text("Basic Sciences")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)

            Text("Build your foundation with structured topics, chapter progression, and high-yield modules for OMFS training.")
                .font(.system(size: 17))
                .foregroundStyle(.white.opacity(0.82))
        }
    }

    private var actionRow: some View {
        HStack(spacing: 14) {
            Button {
            } label: {
                Text("+ Start New Discussion")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        LinearGradient(colors: [Color(red: 0.08, green: 0.29, blue: 0.95), Color(red: 0.12, green: 0.55, blue: 0.98)], startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.55))
                TextField("Search topics...", text: $searchText)
                    .foregroundStyle(.white)
                    .tint(.white)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 17)
            .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TopicFilter.allCases) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(selectedFilter == filter ? 0.98 : 0.78))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(selectedFilter == filter ? Color.blue.opacity(0.34) : Color.white.opacity(0.08))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var moduleGrid: some View {
        LazyVGrid(columns: dashboardColumns, spacing: 16) {
            ForEach(filteredModules) { module in
                Button {
                    navigate(.module(module))
                } label: {
                    DashboardModuleCard(module: module)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var statsStrip: some View {
        HStack {
            StatBlock(label: "TOPICS", value: "\(filteredModules.count)")
            Spacer()
            StatBlock(label: "LESSONS", value: "\(filteredModules.map(\.lessons).reduce(0, +))+")
            Spacer()
            StatBlock(label: "AVG COMPLETION", value: averageCompletionText)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct ModuleDetailScreen: View {
    let module: LearningModule
    let navigate: (Route) -> Void

    var body: some View {
        ZStack {
            DashboardBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(module.category.badgeTitle)
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(.white.opacity(0.12), in: Capsule())

                        Text(module.title)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                        Text(module.subtitle)
                            .font(.system(size: 17))
                            .foregroundStyle(.white.opacity(0.82))
                        ProgressView(value: module.completion)
                            .tint(.cyan)
                        Text("\(module.lessons) lessons • \(Int(module.completion * 100))% complete")
                            .foregroundStyle(.cyan)
                    }
                    .padding(22)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                    ForEach(Array(module.chapters.enumerated()), id: \.element.id) { index, chapter in
                        Button {
                            navigate(.chapter(module: module, chapter: chapter, index: index + 1))
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Chapter \(index + 1)")
                                        .font(.caption.bold())
                                        .foregroundStyle(.cyan)
                                    Text(chapter.title)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text(chapter.description)
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.75))
                                }

                                Spacer(minLength: 0)

                                Image(systemName: "chevron.right")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.65))
                                    .padding(.top, 2)
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(22)
            }
        }
        .navigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

private struct ResourcesScreen: View {
    @State private var query = ""
    @State private var activeTab = "Datasets"

    private var filteredCards: [ResourceCard] {
        OMSHubData.resourceCards.filter { card in
            let matchesTab = activeTab == "All" || card.category == activeTab
            let matchesQuery = query.isEmpty || "\(card.title) \(card.subtitle) \(card.category) \(card.team) \(card.tags.joined(separator: " "))".localizedCaseInsensitiveContains(query)
            return matchesTab && matchesQuery
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Research Hub")
                        .font(.system(size: 38, weight: .bold))
                    Text("Access datasets, protocols, literature, projects, and tools to drive innovation in OMFS research.")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search the Research Hub...", text: $query)
                }
                .padding(16)
                .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(OMSHubData.resourceTabs, id: \.self) { tab in
                            Button {
                                activeTab = tab
                            } label: {
                                Text(tab)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(activeTab == tab ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(activeTab == tab ? Color.blue : Color.white, in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                ForEach(filteredCards) { card in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(card.title)
                            .font(.title2.bold())
                        Text(card.subtitle)
                            .foregroundStyle(.secondary)
                        Text(card.team)
                            .font(.headline)
                            .foregroundStyle(.blue)
                        FlowTags(tags: card.tags)
                        HStack {
                            Text("\(card.uses) uses")
                            Spacer()
                            Text("\(card.citations) citations")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .background(
                        LinearGradient(colors: card.colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.4), lineWidth: 1)
                    )
                }
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Resources")
    }
}

private struct ChapterDetailScreen: View {
    let module: LearningModule
    let chapter: Chapter
    let chapterIndex: Int

    private var breadcrumbText: String {
        if let path = chapter.webPath(in: module) {
            return "OMSHUB Section • \(path)"
        }

        return "OMSHUB Section"
    }

    private var relatedChapters: [Chapter] {
        module.chapters.filter { $0.id != chapter.id }.prefix(3).map { $0 }
    }

    private var isPathologyGrowthChapter: Bool {
        module.subtopicSlug == "pathology" &&
        chapter.webPath(in: module) == "/basic-sciences/pathology/growth-adaptations-cellular-injury-and-cell-death"
    }

    var body: some View {
        Group {
            if isPathologyGrowthChapter {
                PathologyGrowthAdaptationsChapterScreen(module: module, chapter: chapter)
            } else {
                ZStack {
                    DashboardBackground()

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 22) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(module.category.badgeTitle)
                                    .font(.caption.bold())
                                    .foregroundStyle(.white.opacity(0.9))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(.white.opacity(0.12), in: Capsule())

                                Text("Chapter \(chapterIndex)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.cyan)

                                Text(chapter.title)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.white)

                                Text(module.title)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.78))

                                Text(breadcrumbText)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.58))
                            }
                            .padding(22)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                            VStack(alignment: .leading, spacing: 14) {
                                Text("Overview")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text(chapter.description)
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white.opacity(0.84))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(22)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                            if let webPath = chapter.webPath(in: module) {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("OMSHUB Section")
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Text(webPath)
                                        .font(.system(size: 17, weight: .medium, design: .monospaced))
                                        .foregroundStyle(.cyan)
                                        .textSelection(.enabled)
                                }
                                .padding(22)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            }

                            VStack(alignment: .leading, spacing: 14) {
                                Text("Module Context")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text(module.subtitle)
                                    .foregroundStyle(.white.opacity(0.78))

                                HStack {
                                    StatBlock(label: "LESSONS", value: "\(module.lessons)")
                                    Spacer()
                                    StatBlock(label: "PROGRESS", value: "\(Int(module.completion * 100))%")
                                }
                            }
                            .padding(22)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                            if !relatedChapters.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("Related Sections")
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    ForEach(relatedChapters) { related in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(related.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.white)
                                            if let relatedPath = related.webPath(in: module) {
                                                Text(relatedPath)
                                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                                    .foregroundStyle(.white.opacity(0.6))
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding(22)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            }
                        }
                        .padding(22)
                    }
                }
            }
        }
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(isPathologyGrowthChapter ? .light : .dark, for: .navigationBar)
        .toolbarBackground(isPathologyGrowthChapter ? .visible : .hidden, for: .navigationBar)
    }
}

private struct PathologyGrowthAdaptationsChapterScreen: View {
    let module: LearningModule
    let chapter: Chapter

    private let objectives = [
        "Differentiate reversible from irreversible cell injury.",
        "Compare apoptosis and necrosis by mechanism and morphology.",
        "Apply growth adaptation patterns to pathology diagnosis."
    ]

    private let resources = [
        "Pathology Core PDF",
        "Morphology Image Sheet",
        "Practice MCQs"
    ]

    private let quickCheck = [
        "Which finding most strongly indicates irreversible injury?",
        "How does apoptosis differ from necrosis on histology?",
        "Which adaptation pattern best explains this clinical scenario?"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("LECTURES  ›  BASIC SCIENCES  ›  PATHOLOGY")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)
                    Text(chapter.title)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color(red: 0.07, green: 0.11, blue: 0.24))
                    Text("Core pathology framework for growth adaptations, cellular injury progression, and mechanisms of cell death.")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(red: 0.31, green: 0.38, blue: 0.50))
                }

                PathologyMetricCard(title: "Progress") {
                    VStack(alignment: .leading, spacing: 12) {
                        ChapterProgressBar(value: 0.48)
                        Text("48% complete")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.25, green: 0.31, blue: 0.43))
                        ForEach(objectives, id: \.self) { objective in
                            Text("• \(objective)")
                                .font(.system(size: 18))
                                .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.47))
                        }
                    }
                }

                PathologyMetricCard(title: "Lecture Focus", trailing: "48% complete") {
                    VStack(alignment: .leading, spacing: 14) {
                        ChapterProgressBar(value: 0.48)
                        ForEach(objectives, id: \.self) { objective in
                            Label(objective, systemImage: "checkmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.47))
                        }
                    }
                }

                PathologyMetricCard(title: "Resources") {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(resources, id: \.self) { resource in
                            Text("☑ \(resource)")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.47))
                        }
                    }
                }

                PathologyMetricCard(title: "Quick Check") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(quickCheck, id: \.self) { question in
                            Text("• \(question)")
                                .font(.system(size: 18))
                                .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.47))
                        }

                        Text("Inflammation & Wound Healing")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(colors: [Color(red: 0.14, green: 0.29, blue: 0.92), Color(red: 0.04, green: 0.63, blue: 0.86)], startPoint: .leading, endPoint: .trailing),
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                    }
                }

                PathologyMetricCard(title: "Growth Adaptations, Cellular Injury & Cell Death (rapid map)") {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Hypertrophy/hyperplasia, reversible vs irreversible injury, necrosis, apoptosis, free radical injury, and amyloidosis.")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(red: 0.31, green: 0.38, blue: 0.50))

                        Image("pathology_neoplasia_map")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )

                        Text("Click image to expand. Click outside image or press Esc to close.")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Clinical connection")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                            Text("Clinical connection: pattern recognition across adaptation, injury, and death pathways improves differential diagnosis and urgency decisions.")
                                .font(.system(size: 18))
                                .foregroundStyle(.white.opacity(0.92))
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            LinearGradient(colors: [Color(red: 0.24, green: 0.22, blue: 0.84), Color(red: 0.13, green: 0.36, blue: 0.88)], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                    }
                }

                PathologyArticleCard(title: "1. Fundamental Tumor Biology: Monoclonality and Classification") {
                    Text("The shift from normal cellular homeostasis to neoplastic growth represents a catastrophic failure of the deterministic signals governing tissue architecture and cellular proliferation. In the physiological state, cell cycle control is maintained by a complex regulatory network; however, neoplasia arises when the enabling characteristic of Genome Instability and Mutation permits the bypass of these constraints. Understanding the monoclonal origin of tumors is essential for targeted therapeutic interventions.")
                    Text("Tumor nomenclature is fundamentally bifurcated by biological behavior into benign and malignant. Benign tumors are generally localized, whereas malignant neoplasms breach the basement membrane and destroy surrounding architecture. Central to this process is monoclonality: neoplasms originate from the transformation of a single cell that acquires a selective growth advantage.")

                    Text("Comparative Analysis of Neoplasms")
                        .font(.title3.bold())
                        .foregroundStyle(Color(red: 0.07, green: 0.11, blue: 0.24))
                        .padding(.top, 8)

                    VStack(spacing: 10) {
                        ComparisonRow(criteria: "Differentiation / Anaplasia", benign: "Well-differentiated; resembles tissue of origin.", malignant: "Ranges from well-differentiated to anaplastic.")
                        ComparisonRow(criteria: "Rate of Growth", benign: "Usually slow; may stop or regress.", malignant: "Typically rapid; erratic or autonomous.")
                        ComparisonRow(criteria: "Boundary", benign: "Circumscribed or encapsulated.", malignant: "Irregular; infiltrative.")
                        ComparisonRow(criteria: "Local Invasion", benign: "Does not invade; remains localized.", malignant: "Infiltrative and destructive to basement membrane.")
                        ComparisonRow(criteria: "Metastasis", benign: "Absent.", malignant: "Frequently present; the defining lethal trait.")
                    }

                    Text("The biological divergence between benign and malignant tumors dictates treatment selection. Benign tumors often allow watchful waiting or simple excision, while malignant tumors require aggressive multi-modal management because dissemination remains the primary driver of cancer-related mortality.")
                }

                PathologyArticleCard(title: "2. Carcinogenesis: The Molecular Logic of Transformation") {
                    Text("Carcinogenesis is governed by the Multistep Mutation Theory, where cumulative genetic and epigenetic insults progressively dismantle cellular checks and balances.")
                    BulletList(items: [
                        "Oncogenes: KRAS or BRAF mutations trigger the Ras/MAPK cascade and sustain proliferative signaling.",
                        "Tumor suppressor genes: APC and TP53 loss drive chromosomal instability and disable apoptosis or senescence responses.",
                        "DNA repair genes: mismatch repair failure produces microsatellite instability."
                    ])
                    Text("MSI-high tumors carry high mutational loads and may respond to PD-1 inhibition because their neoantigen burden makes them more visible to the immune system.")
                }

                PathologyArticleCard(title: "3. Phenotypic Plasticity and the Hallmarks of Cancer") {
                    Text("Phenotypic plasticity allows cancer cells to escape terminal differentiation and adopt progenitor-like states through nonmutational epigenetic reprogramming.")
                    BulletList(items: [
                        "Dedifferentiation: epithelial-mesenchymal transition with loss of polarity and acquisition of motility.",
                        "Blocked differentiation: progenitor cells remain highly proliferative, as seen in acute myeloid leukemia.",
                        "Transdifferentiation: one differentiated cell type adopts another lineage, as in Barrett esophagus."
                    ])
                    Text("This framework explains why differentiation therapy can restore maturation and induce remission in selected leukemias.")
                }

                PathologyArticleCard(title: "4. Mechanisms of Tumor Progression: Invasion and the Metastatic Cascade") {
                    Text("The metastatic cascade remains the primary cause of cancer death. Tumor cells must overcome structural, physiologic, and immunologic barriers to disseminate successfully.")
                    BulletList(items: [
                        "Collective invasion uses coordinated clusters and tip cells to remodel extracellular matrix.",
                        "Mesenchymal-to-amoeboid transition permits rapid protease-independent migration through matrix gaps.",
                        "Tumor-microenvironment signaling through fibroblasts, chemokines, integrins, and MMPs supports migration and intravasation."
                    ])
                }

                PathologyArticleCard(title: "5. Clinical Evaluation: Grading, Staging, and Screening Principles") {
                    Text("Pathological grading and clinical staging convert molecular complexity into a practical roadmap for management.")
                    BulletList(items: [
                        "Grading: degree of differentiation and cytologic atypia.",
                        "Staging: TNM assessment of tumor size, nodal spread, and metastasis.",
                        "Seed and soil theory: metastasis depends on compatibility between tumor phenotype and target-organ microenvironment."
                    ])
                }

                PathologyArticleCard(title: "6. Works Cited") {
                    BulletList(items: [
                        "Cell Signaling Technology. Hallmarks of cancer: Unlocking phenotypic plasticity.",
                        "Hanahan D. Hallmarks of cancer: New dimensions.",
                        "Hanahan D, Weinberg RA. Hallmarks of cancer: The next generation.",
                        "Pierantoni C, Cosentino L, Ricciardiello L. Molecular pathways of colorectal cancer development.",
                        "van Zijl F, Krupitza G, Mikulits W. Initial steps of metastasis: Cell invasion and endothelial transmigration."
                    ])
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Pearl")
                        .font(.caption.bold())
                        .textCase(.uppercase)
                        .foregroundStyle(Color.cyan)
                    Text("ATP depletion, membrane damage, and DNA/protein response pathways.")
                        .font(.title3.bold())
                        .foregroundStyle(Color(red: 0.07, green: 0.11, blue: 0.24))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(colors: [Color.cyan.opacity(0.12), Color.blue.opacity(0.10)], startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
            }
            .padding(20)
        }
        .background(
            LinearGradient(colors: [Color(red: 0.97, green: 0.98, blue: 1.0), Color(red: 0.91, green: 0.94, blue: 0.99)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

private struct PathologyMetricCard<Content: View>: View {
    let title: String
    var trailing: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(red: 0.07, green: 0.11, blue: 0.24))
                Spacer()
                if let trailing {
                    Text(trailing)
                        .font(.headline)
                        .foregroundStyle(Color.blue)
                }
            }
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct PathologyArticleCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color(red: 0.07, green: 0.11, blue: 0.24))
            content
                .font(.system(size: 18))
                .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.47))
                .lineSpacing(6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct ChapterProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(Color(red: 0.86, green: 0.89, blue: 0.94))
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(
                        LinearGradient(colors: [Color(red: 0.20, green: 0.48, blue: 0.97), Color(red: 0.04, green: 0.74, blue: 0.86)], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: proxy.size.width * value)
            }
        }
        .frame(height: 10)
    }
}

private struct BulletList: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Text("•")
                    Text(item)
                }
            }
        }
    }
}

private struct ComparisonRow: View {
    let criteria: String
    let benign: String
    let malignant: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(criteria)
                .font(.headline)
                .foregroundStyle(Color(red: 0.07, green: 0.11, blue: 0.24))
            VStack(alignment: .leading, spacing: 8) {
                Text("Benign: \(benign)")
                Text("Malignant: \(malignant)")
            }
            .font(.system(size: 17))
            .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.47))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.96, green: 0.97, blue: 1.0), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct CommunityScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Coming Soon")
                    .font(.system(size: 36, weight: .bold))
                Text("This page is being built.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Community")
    }
}

private struct AccountScreen: View {
    let navigate: (Route) -> Void
    @State private var loggedIn = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if loggedIn {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Account")
                            .font(.caption.bold())
                            .foregroundStyle(.blue)
                        Text("Welcome, Cheyenne")
                            .font(.system(size: 34, weight: .bold))
                        Text("Signed in as cheyenne@example.com")
                            .foregroundStyle(.secondary)
                    }

                    Button("Open Curriculum") {
                        navigate(.basicSciences)
                    }
                    .buttonStyle(AccountLinkStyle())

                    Button("Research Hub") {
                        navigate(.resources)
                    }
                    .buttonStyle(AccountLinkStyle())

                    Button("Community") {
                        navigate(.community)
                    }
                    .buttonStyle(AccountLinkStyle())
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Account")
                            .font(.system(size: 34, weight: .bold))
                        Text("The OMSHUB website redirects signed-out users to login before opening the account page. This native version keeps the same flow.")
                            .foregroundStyle(.secondary)
                    }

                    Button("Log In") {
                        navigate(.login)
                    }
                    .buttonStyle(AccountLinkStyle())

                    Button("Create Account") {
                        navigate(.signup)
                    }
                    .buttonStyle(AccountLinkStyle())

                    Button("Preview Signed-In Account") {
                        loggedIn = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Account")
    }
}

private struct NewsScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("News")
                        .font(.system(size: 38, weight: .bold))
                    Text("Latest updates for events, career opportunities, and specialty news.")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Events")
                        .font(.title2.bold())
                    ForEach(OMSHubData.events, id: \.self) { item in
                        NewsCard(title: item, detail: "Registration details and agenda published soon.")
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Job Opportunities")
                        .font(.title2.bold())
                    ForEach(OMSHubData.jobs, id: \.self) { item in
                        NewsCard(title: item, detail: "")
                    }
                }
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("News")
    }
}

private struct AboutScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("OMS Nexus")
                        .font(.caption.bold())
                        .foregroundStyle(.blue)
                    Text("About Our Learning Hub")
                        .font(.system(size: 36, weight: .bold))
                    Text("We build practical, structured education for oral and maxillofacial surgery trainees, with focused tracks across basic sciences, surgery, anatomy, pharmacology, and research.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 16) {
                    AboutCard(title: "Mission", bodyText: "Deliver clear, high-yield teaching for OMFS learners at every level.")
                    AboutCard(title: "Approach", bodyText: "Case-based lessons, chapter progression, and practical clinical framing.")
                    AboutCard(title: "Community", bodyText: "Collaborative space for trainees, educators, and specialty professionals.")
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Contact Us")
                        .font(.title2.bold())
                    Text("For partnerships, speaking requests, or contributor opportunities, reach out and include your area of interest.")
                        .foregroundStyle(.secondary)
                    HStack(spacing: 16) {
                        ContactCard(label: "Email", value: "contact@omsacademy.org")
                        ContactCard(label: "Collaboration", value: "community@omsacademy.org")
                    }
                }
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("About")
    }
}

private struct LoginScreen: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        FormCardScreen(title: "Log In", subtitle: "Sign in to continue to your OMSHUB account.") {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            SecureField("Password", text: $password)
            Button("Sign In") {}
                .buttonStyle(.borderedProminent)
        }
    }
}

private struct SignupScreen: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        FormCardScreen(title: "Create Account", subtitle: "Create a native OMS Nexus account experience modeled on OMSHUB.") {
            TextField("Full Name", text: $name)
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            SecureField("Password", text: $password)
            Button("Create Account") {}
                .buttonStyle(.borderedProminent)
        }
    }
}

private struct PlaceholderScreen: View {
    let title: String
    let subtitle: String
    let accent: Color

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(size: 36, weight: .bold))
                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct FormCardScreen<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(size: 34, weight: .bold))
                Text(subtitle)
                    .foregroundStyle(.secondary)
                content
            }
            .textFieldStyle(.roundedBorder)
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(title)
    }
}

private struct NewsCard: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            if !detail.isEmpty {
                Text(detail)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct AboutCard: View {
    let title: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3.bold())
            Text(bodyText)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct ContactCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct FlowTags: View {
    let tags: [String]

    var body: some View {
        HStack {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.6), in: Capsule())
            }
        }
    }
}

private struct DashboardBackground: View {
    var body: some View {
        LinearGradient(colors: [Color(red: 0.02, green: 0.08, blue: 0.24), Color(red: 0.04, green: 0.16, blue: 0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay(
                RadialGradient(colors: [Color(red: 0.10, green: 0.29, blue: 0.84).opacity(0.45), .clear], center: .topLeading, startRadius: 40, endRadius: 480)
                    .ignoresSafeArea()
            )
    }
}

private struct DashboardModuleCard: View {
    let module: LearningModule

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(module.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                .overlay(
                    LinearGradient(colors: [module.colors.first?.opacity(0.55) ?? .clear, .black.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(module.category.badgeTitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.92))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.12), in: Capsule())

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white.opacity(0.72))
                }

                Spacer()

                Text(module.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .multilineTextAlignment(.leading)
                Text("\(module.lessons) Lessons • \(Int(module.completion * 100))% Complete")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                ProgressView(value: module.completion)
                    .tint(.cyan)
            }
            .padding(18)
        }
        .frame(minHeight: 240)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct SectionTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private struct StatBlock: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .tracking(1.1)
                .foregroundStyle(.white.opacity(0.62))
            Text(value)
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

private struct AccountLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private enum AppTab {
    case home
    case lectures
    case resources
    case community
    case account
}

private enum Route: Hashable {
    case basicSciences
    case module(LearningModule)
    case chapter(module: LearningModule, chapter: Chapter, index: Int)
    case news
    case about
    case login
    case signup
    case account
    case resources
    case community
    case anatomyHub
    case surgeryHub
    case pharmacologyHub
}

private struct FeaturePanel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let route: Route
    let cta: String
    let keywords: String
}

private struct NewsItem: Identifiable {
    let id = UUID()
    let category: String
    let title: String
}

private struct LectureCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]
    let keywords: String
    let route: Route
    let items: [LectureCategoryItem]
}

private struct LectureCategoryItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let module: LearningModule?
}

private struct LearningModule: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: TopicFilter
    let subtopicSlug: String?
    let lessons: Int
    let completion: Double
    let imageName: String
    let colors: [Color]
    let chapters: [Chapter]
}

private struct Chapter: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let webSlug: String?

    init(title: String, description: String, webSlug: String? = nil) {
        self.title = title
        self.description = description
        self.webSlug = webSlug
    }

    func webPath(in module: LearningModule) -> String? {
        guard let subtopicSlug = module.subtopicSlug else { return nil }
        let chapterSlug = webSlug ?? slugifiedSegment(from: title)
        return "/basic-sciences/\(subtopicSlug)/\(chapterSlug)"
    }

    func websiteURL(in module: LearningModule) -> URL? {
        guard let webPath = webPath(in: module) else { return nil }
        return URL(string: "\(OMSHubWebsite.baseURL)\(webPath)")
    }
}

private struct ResourceCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let team: String
    let tags: [String]
    let uses: Int
    let citations: Int
    let colors: [Color]
}

private enum TopicFilter: String, CaseIterable, Identifiable, Hashable {
    case all
    case fundamental
    case clinical
    case advanced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .fundamental: return "Fundamental"
        case .clinical: return "Clinical"
        case .advanced: return "Advanced"
        }
    }

    var badgeTitle: String { rawValue.uppercased() }
}

private func slugifiedSegment(from text: String) -> String {
    text
        .lowercased()
        .replacingOccurrences(of: "&", with: " and ")
        .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
        .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
}

private enum OMSHubWebsite {
    static let baseURL = "https://oms-biord.vercel.app"
}

private enum OMSHubData {
    static let basicScienceModules: [LearningModule] = [
        LearningModule(title: "Cell Biology", subtitle: "Foundational and clinical cell biology topics.", category: .fundamental, subtopicSlug: "cell-biology", lessons: 12, completion: 0.80, imageName: "cellbio1", colors: [Color(red: 0.43, green: 0.20, blue: 0.85), Color(red: 0.16, green: 0.54, blue: 0.98)], chapters: [
            Chapter(title: "Cell Structure & Organization", description: "Types of cells, organelles, cytoskeleton, and extracellular matrix."),
            Chapter(title: "Cell Membrane & Transport", description: "Membrane structure, passive and active transport, ion channels."),
            Chapter(title: "Organelles", description: "Nucleus, mitochondria, ER, Golgi apparatus, and lysosomes."),
            Chapter(title: "Cell Signaling", description: "Signal transduction pathways and intracellular communication."),
            Chapter(title: "DNA, RNA & Protein Synthesis", description: "Replication, transcription, translation, and protein folding."),
            Chapter(title: "Cell Cycle & Division", description: "Mitosis, meiosis, checkpoints, and cycle control.")
        ]),
        LearningModule(title: "Immunology", subtitle: "Core immunology principles relevant to OMFS and clinical medicine.", category: .clinical, subtopicSlug: "immunology", lessons: 10, completion: 0.60, imageName: "immuno1", colors: [Color(red: 0.18, green: 0.33, blue: 0.73), Color(red: 0.35, green: 0.56, blue: 0.95)], chapters: [
            Chapter(title: "Innate Immunity", description: "Barriers, complement, neutrophils, and macrophage responses."),
            Chapter(title: "Adaptive Immunity", description: "B-cell and T-cell activation, specificity, and memory."),
            Chapter(title: "Antigen Presentation", description: "MHC pathways and cellular signaling in antigen display."),
            Chapter(title: "Inflammation & Cytokines", description: "Key cytokines, chemokines, and inflammatory cascades."),
            Chapter(title: "Hypersensitivity", description: "Type I-IV reactions and immune-mediated pathology."),
            Chapter(title: "Clinical Immunology", description: "Immunologic disorders and perioperative implications.")
        ]),
        LearningModule(title: "Pathology", subtitle: "Pathology foundations for diagnosis, treatment planning, and surgery.", category: .clinical, subtopicSlug: "pathology", lessons: 8, completion: 0.70, imageName: "pathology1", colors: [Color(red: 0.41, green: 0.29, blue: 0.66), Color(red: 0.24, green: 0.47, blue: 0.88)], chapters: [
            Chapter(title: "Growth Adaptations, Cellular Injury & Cell Death", description: "Hypertrophy/hyperplasia, reversible vs irreversible injury, necrosis, apoptosis, free radical injury, and amyloidosis."),
            Chapter(title: "Inflammation & Wound Healing", description: "Acute/chronic inflammation, immunodeficiency, autoimmune disease, and wound healing pathways including scars and dehiscence."),
            Chapter(title: "Principles of Neoplasia", description: "Tumor biology, carcinogenesis genes, invasion, metastasis, angiogenesis, and TNM staging."),
            Chapter(title: "Hemostasis & Related Disorders", description: "Platelet adhesion, coagulation cascade, PT/PTT interpretation, and disorders such as hemophilia, vWD, DIC, TTP/HUS, and HIT."),
            Chapter(title: "Red Blood Cell Disorders", description: "Microcytic, normocytic, and macrocytic anemias with hemoglobinopathies including sickle cell and thalassemias."),
            Chapter(title: "White Blood Cell Disorders", description: "Leukocytosis/leukopenia, acute/chronic leukemias, Hodgkin and non-Hodgkin lymphoma, and plasma cell disorders.")
        ]),
        LearningModule(title: "Hematology-Oncology", subtitle: "Blood disorders and oncology principles relevant to OMFS care.", category: .advanced, subtopicSlug: "hematology-oncology", lessons: 11, completion: 0.55, imageName: "logo2", colors: [Color(red: 0.18, green: 0.36, blue: 0.83), Color(red: 0.29, green: 0.65, blue: 0.96)], chapters: [
            Chapter(title: "Hematopoiesis", description: "Bone marrow biology and blood cell line development."),
            Chapter(title: "Anemia Workup", description: "Classification and diagnostic framework for anemia."),
            Chapter(title: "Coagulation", description: "Platelet and clotting pathways in surgical care."),
            Chapter(title: "Leukemias & Lymphomas", description: "Clinical patterns, staging, and therapeutic overview."),
            Chapter(title: "Solid Tumor Biology", description: "Oncogenesis and tumor spread principles."),
            Chapter(title: "Perioperative Oncology", description: "Surgical implications and treatment sequencing.")
        ]),
        LearningModule(title: "Inflammation and Healing", subtitle: "Mechanisms of inflammation and tissue repair in surgical contexts.", category: .clinical, subtopicSlug: "inflammation-healing", lessons: 9, completion: 0.50, imageName: "logo2", colors: [Color(red: 0.15, green: 0.38, blue: 0.80), Color(red: 0.30, green: 0.51, blue: 0.93)], chapters: [
            Chapter(title: "Acute Inflammatory Response", description: "Vascular and cellular events in acute inflammation."),
            Chapter(title: "Chronic Inflammation", description: "Persistent inflammation and tissue remodeling."),
            Chapter(title: "Mediators of Inflammation", description: "Histamine, prostaglandins, cytokines, and cascades."),
            Chapter(title: "Phases of Wound Healing", description: "Hemostasis, proliferation, and maturation timelines."),
            Chapter(title: "Impaired Healing", description: "Infection, ischemia, systemic factors, and risks."),
            Chapter(title: "Healing in OMFS", description: "Soft tissue and bone healing in maxillofacial surgery.")
        ]),
        LearningModule(title: "Microbiology", subtitle: "Microbial fundamentals and infection control for OMFS practice.", category: .fundamental, subtopicSlug: "microbiology", lessons: 7, completion: 0.45, imageName: "logo_nobackground", colors: [Color(red: 0.17, green: 0.39, blue: 0.82), Color(red: 0.23, green: 0.53, blue: 0.90)], chapters: [
            Chapter(title: "Bacterial Classification", description: "Morphology, staining, growth, and virulence."),
            Chapter(title: "Viral Principles", description: "Viral structure, replication, and host interaction."),
            Chapter(title: "Fungal & Parasitic Infections", description: "Major organisms and diagnostic principles."),
            Chapter(title: "Biofilms", description: "Biofilm biology in oral and implant-related disease."),
            Chapter(title: "Antimicrobial Stewardship", description: "Selection, resistance, and therapy optimization."),
            Chapter(title: "Infection Control", description: "Sterilization protocols and operative prevention.")
        ]),
        LearningModule(title: "Microbiology Essentials", subtitle: "High-yield microbiology concepts for clinical and board review.", category: .advanced, subtopicSlug: "microbiology-essentials", lessons: 10, completion: 0.65, imageName: "logo_nobackground", colors: [Color(red: 0.13, green: 0.31, blue: 0.74), Color(red: 0.22, green: 0.58, blue: 0.98)], chapters: [
            Chapter(title: "Essential Bacteria", description: "Core bacteria, Gram patterns, and clinical relevance."),
            Chapter(title: "Essential Viruses", description: "High-yield viruses and pathogenesis clues."),
            Chapter(title: "Key Antimicrobials", description: "Mechanisms, side effects, and OMFS use-cases."),
            Chapter(title: "Oral Infections", description: "Common odontogenic and maxillofacial infections."),
            Chapter(title: "Rapid Diagnostics", description: "Culture, PCR, susceptibility, and interpretation."),
            Chapter(title: "Case Review", description: "Integrated case-based microbiology decision-making.")
        ])
    ]

    static let lectureCategories: [LectureCategory] = [
        LectureCategory(title: "Basic Sciences", subtitle: "Fundamentals of Medical Science", icon: "🧬", colors: [Color.blue, Color.cyan], keywords: "all popular new basic science fundamentals", route: .basicSciences, items: basicScienceModules.map {
            LectureCategoryItem(title: $0.title, subtitle: $0.subtitle, module: $0)
        }),
        LectureCategory(title: "Anatomy & Radiology", subtitle: "Build clinical confidence with structured anatomy, imaging pathways, and high-yield diagnostic modules for OMFS training.", icon: "💀", colors: [Color.indigo, Color.purple], keywords: "all popular new anatomy radiology imaging diagnostics", route: .anatomyHub, items: anatomyModules.map {
            LectureCategoryItem(title: $0.title, subtitle: $0.subtitle, module: $0)
        }),
        LectureCategory(title: "Surgery & Anesthesiology", subtitle: "Learn core operative planning, anesthesia strategy, and perioperative decision-making through structured OMFS modules.", icon: "🩺", colors: [Color.teal, Color.green], keywords: "all popular new surgery anesthesia procedures", route: .surgeryHub, items: surgeryModules.map {
            LectureCategoryItem(title: $0.title, subtitle: $0.subtitle, module: $0)
        }),
        LectureCategory(title: "Pharmacology", subtitle: "Drugs, mechanisms, and clinical application pathways for OMFS-focused training.", icon: "💊", colors: [Color.orange, Color.red], keywords: "all popular new pharmacology medications therapeutics drugs", route: .pharmacologyHub, items: pharmacologyModules.map {
            LectureCategoryItem(title: $0.title, subtitle: $0.subtitle, module: $0)
        })
    ]

    static let anatomyModules: [LearningModule] = [
        LearningModule(title: "Head and Neck Anatomy", subtitle: "Core surgical anatomy for OMFS.", category: .fundamental, subtopicSlug: nil, lessons: 12, completion: 0.80, imageName: "homepage", colors: [Color.indigo, Color.blue], chapters: [
            Chapter(title: "Skull Base", description: "Key foramina, fissures, and neurovascular passageways."),
            Chapter(title: "Muscles of Mastication", description: "Anatomy, function, and surgical relevance."),
            Chapter(title: "Vascular Supply", description: "Arterial and venous systems of the face and neck.")
        ]),
        LearningModule(title: "Radiographic Landmarks", subtitle: "Imaging workflow and diagnostic landmarks.", category: .clinical, subtopicSlug: nil, lessons: 10, completion: 0.62, imageName: "logo2", colors: [Color.cyan, Color.blue], chapters: [
            Chapter(title: "Panoramic Landmarks", description: "Recognize core mandibular and maxillary landmarks."),
            Chapter(title: "Sinus and Nasal Structures", description: "Interpret common radiographic anatomy."),
            Chapter(title: "Pathology Flags", description: "Identify abnormal radiographic patterns.")
        ]),
        LearningModule(title: "Cranial Nerve Mapping", subtitle: "Clinical anatomy of facial and trigeminal pathways.", category: .clinical, subtopicSlug: nil, lessons: 8, completion: 0.70, imageName: "pathology1", colors: [Color.purple, Color.blue], chapters: [
            Chapter(title: "CN V", description: "Trigeminal branches and anesthetic targets."),
            Chapter(title: "CN VII", description: "Facial nerve course and operative risk zones."),
            Chapter(title: "Neurologic Deficits", description: "Clinical evaluation of injury patterns.")
        ]),
        LearningModule(title: "Cross-Sectional Imaging", subtitle: "CBCT and CT interpretation for OMFS.", category: .advanced, subtopicSlug: nil, lessons: 11, completion: 0.55, imageName: "logo_nobackground", colors: [Color.blue, Color.indigo], chapters: [
            Chapter(title: "Axial Orientation", description: "Read axial imaging in the maxillofacial region."),
            Chapter(title: "Coronal and Sagittal Views", description: "Correlate multiplanar anatomy."),
            Chapter(title: "Surgical Planning", description: "Use imaging to guide osteotomies and implants.")
        ]),
        LearningModule(title: "Facial Spaces", subtitle: "Spread of infection and operative anatomy.", category: .fundamental, subtopicSlug: nil, lessons: 9, completion: 0.50, imageName: "homepage", colors: [Color.teal, Color.blue], chapters: [
            Chapter(title: "Primary Spaces", description: "Buccal, submandibular, sublingual, and canine spaces."),
            Chapter(title: "Secondary Spaces", description: "Deep fascial spread and airway risk."),
            Chapter(title: "Drainage Approaches", description: "Surgical access patterns and precautions.")
        ]),
        LearningModule(title: "CBCT Essentials", subtitle: "High-yield imaging workflow for residents.", category: .advanced, subtopicSlug: nil, lessons: 7, completion: 0.45, imageName: "cellbio1", colors: [Color.cyan, Color.mint], chapters: [
            Chapter(title: "Image Acquisition", description: "Core acquisition concepts and artifacts."),
            Chapter(title: "Interpretation Checklist", description: "Systematic review of CBCT studies."),
            Chapter(title: "Reporting", description: "Document findings for clinical decision-making.")
        ])
    ]

    static let surgeryModules: [LearningModule] = [
        LearningModule(title: "Preoperative Planning", subtitle: "Structured surgical planning fundamentals.", category: .fundamental, subtopicSlug: nil, lessons: 12, completion: 0.78, imageName: "homepage", colors: [Color.teal, Color.blue], chapters: [
            Chapter(title: "Evaluation", description: "History, imaging, and surgical readiness."),
            Chapter(title: "Consent", description: "Risk communication and procedure planning."),
            Chapter(title: "Setup", description: "Operative sequencing and room preparation.")
        ]),
        LearningModule(title: "Airway & Anesthesia Basics", subtitle: "Sedation, airway, and monitoring.", category: .clinical, subtopicSlug: nil, lessons: 10, completion: 0.60, imageName: "logo2", colors: [Color.green, Color.teal], chapters: [
            Chapter(title: "Airway Assessment", description: "Predict difficulty and escalation strategy."),
            Chapter(title: "Monitoring", description: "Perioperative monitoring and thresholds."),
            Chapter(title: "Complication Response", description: "Recognize and manage anesthesia events.")
        ]),
        LearningModule(title: "Trauma Surgery Principles", subtitle: "Assessment and fixation concepts.", category: .clinical, subtopicSlug: nil, lessons: 8, completion: 0.72, imageName: "pathology1", colors: [Color.red, Color.orange], chapters: [
            Chapter(title: "ATLS Integration", description: "Initial trauma workflow in OMFS settings."),
            Chapter(title: "Fracture Patterns", description: "Mandible, zygoma, orbit, and midface review."),
            Chapter(title: "Fixation Strategy", description: "Choosing plates, screws, and sequencing.")
        ]),
        LearningModule(title: "Perioperative Risk Management", subtitle: "Managing higher-risk surgical patients.", category: .advanced, subtopicSlug: nil, lessons: 11, completion: 0.52, imageName: "logo_nobackground", colors: [Color.indigo, Color.blue], chapters: [
            Chapter(title: "Medical Optimization", description: "Assess systemic disease before surgery."),
            Chapter(title: "Bleeding Risk", description: "Anticoagulation, labs, and mitigation."),
            Chapter(title: "Post-op Surveillance", description: "Monitoring pathways and escalation.")
        ]),
        LearningModule(title: "Complication Prevention", subtitle: "Reduce common surgical failures.", category: .fundamental, subtopicSlug: nil, lessons: 9, completion: 0.48, imageName: "homepage", colors: [Color.cyan, Color.blue], chapters: [
            Chapter(title: "Sterility", description: "Field discipline and contamination prevention."),
            Chapter(title: "Tissue Handling", description: "Techniques that reduce wound complications."),
            Chapter(title: "Follow-up", description: "Early detection of post-op issues.")
        ]),
        LearningModule(title: "Advanced Sedation Pathways", subtitle: "Deeper sedation and rescue concepts.", category: .advanced, subtopicSlug: nil, lessons: 7, completion: 0.44, imageName: "cellbio1", colors: [Color.mint, Color.teal], chapters: [
            Chapter(title: "Sedation Planning", description: "Candidate selection and medication planning."),
            Chapter(title: "Emergency Rescue", description: "Airway rescue and reversal steps."),
            Chapter(title: "Documentation", description: "Capture sedation events and compliance.")
        ])
    ]

    static let pharmacologyModules: [LearningModule] = [
        LearningModule(title: "Drug Classes", subtitle: "Broad-spectrum review from antimicrobials to endocrine agents.", category: .fundamental, subtopicSlug: nil, lessons: 10, completion: 0.68, imageName: "logo2", colors: [Color.cyan, Color.indigo], chapters: [
            Chapter(title: "Antibiotics", description: "High-yield antimicrobial classes for OMFS."),
            Chapter(title: "Cardiovascular Drugs", description: "Common perioperative cardiovascular medications."),
            Chapter(title: "Endocrine Agents", description: "Core endocrine pharmacology overview.")
        ]),
        LearningModule(title: "Mechanisms of Action", subtitle: "Map molecular targets, signaling effects, and downstream outcomes.", category: .clinical, subtopicSlug: nil, lessons: 9, completion: 0.54, imageName: "immuno1", colors: [Color.green, Color.cyan], chapters: [
            Chapter(title: "Receptors", description: "Receptor families and signaling logic."),
            Chapter(title: "Enzyme Targets", description: "Drugs acting through enzyme inhibition."),
            Chapter(title: "Clinical Translation", description: "Connect mechanism to bedside choices.")
        ]),
        LearningModule(title: "Pharmacokinetics", subtitle: "Absorption, distribution, metabolism, and excretion in practice.", category: .fundamental, subtopicSlug: nil, lessons: 8, completion: 0.58, imageName: "homepage", colors: [Color.orange, Color.red], chapters: [
            Chapter(title: "Absorption", description: "Bioavailability and route selection."),
            Chapter(title: "Distribution", description: "Protein binding and tissue penetration."),
            Chapter(title: "Metabolism and Excretion", description: "Hepatic and renal handling.")
        ]),
        LearningModule(title: "Pharmacodynamics", subtitle: "Dose-response, potency, efficacy, and adverse event profiles.", category: .clinical, subtopicSlug: nil, lessons: 8, completion: 0.49, imageName: "pathology1", colors: [Color.purple, Color.indigo], chapters: [
            Chapter(title: "Dose Response", description: "Potency, efficacy, and therapeutic window."),
            Chapter(title: "Toxicity", description: "Recognize adverse effects and monitoring needs."),
            Chapter(title: "Drug Interactions", description: "Mechanisms and clinical implications.")
        ]),
        LearningModule(title: "Clinical Applications", subtitle: "Indications, contraindications, and case-based prescribing logic.", category: .advanced, subtopicSlug: nil, lessons: 11, completion: 0.52, imageName: "logo_nobackground", colors: [Color.orange, Color.pink], chapters: [
            Chapter(title: "Case Selection", description: "Match therapy to patient context."),
            Chapter(title: "Contraindications", description: "Identify when not to prescribe."),
            Chapter(title: "OMFS Use Cases", description: "Sedation, antibiotics, and pain regimens.")
        ]),
        LearningModule(title: "High-Yield Tables", subtitle: "Rapid review matrices for wards, oral boards, and exam prep.", category: .advanced, subtopicSlug: nil, lessons: 7, completion: 0.61, imageName: "cellbio1", colors: [Color.blue, Color.cyan], chapters: [
            Chapter(title: "Rapid Review", description: "Compare classes and indications quickly."),
            Chapter(title: "Board Pearls", description: "High-yield facts for oral board prep."),
            Chapter(title: "Clinical Checklists", description: "Use summary tables in patient care.")
        ])
    ]

    static let featurePanels: [FeaturePanel] = [
        FeaturePanel(title: "Clinical Lectures", description: "Latest: Maxillofacial Trauma Management", route: .basicSciences, cta: "[Browse All Modules]", keywords: "lectures trauma maxillofacial"),
        FeaturePanel(title: "Research & Trials", description: "New Upload: Bone Grafting Meta-Analysis", route: .resources, cta: "[Access Library]", keywords: "research trials library bone grafting"),
        FeaturePanel(title: "Peer Discussion", description: "Active: Management of Third Molar Complications", route: .community, cta: "[Join Conversation]", keywords: "community peer discussion third molar")
    ]

    static let newsItems: [NewsItem] = [
        NewsItem(category: "Events", title: "Coming Soon!"),
        NewsItem(category: "Events", title: "Coming Soon!"),
        NewsItem(category: "News of Interest", title: "New Report: Coming Soon!")
    ]

    static let resourceTabs = ["Datasets", "Protocols", "Literature", "Projects", "Tools"]

    static let resourceCards: [ResourceCard] = [
        ResourceCard(title: "Post-Op Inflammatory Biomarkers", subtitle: "Circulatory inflammation-related microRNA expression data", category: "Datasets", team: "Cytokinetics", tags: ["Deep Learning", "microRNA"], uses: 253, citations: 15, colors: [Color.pink.opacity(0.35), Color.blue.opacity(0.28)]),
        ResourceCard(title: "TMJ Osteoarthritis Proteomics", subtitle: "TMJ degeneration mass spectrometry profiles", category: "Projects", team: "Deep Proteomics", tags: ["Biomarkers", "Mass Spectrometry"], uses: 193, citations: 8, colors: [Color.orange.opacity(0.35), Color.blue.opacity(0.24)]),
        ResourceCard(title: "OSCC Genomic Risk Markers", subtitle: "SNP array data for gene susceptibility and stratification", category: "Literature", team: "OncoGene Sciences", tags: ["Genomic", "Risk Stratification"], uses: 162, citations: 12, colors: [Color.purple.opacity(0.35), Color.blue.opacity(0.24)])
    ]

    static let events = [
        "OMFS Education Symposium - March 15",
        "Resident Case Review Webinar - April 2"
    ]

    static let jobs = [
        "Clinical Educator - Maxillofacial Surgery",
        "Research Associate - Surgical Outcomes",
        "Curriculum Coordinator - Digital Learning"
    ]
}

#Preview {
    ContentView()
}
