# State Management Guide

This document clarifies when to use **Bloc** vs **ChangeNotifier** in the UyDosh app and provides guidance for new features.

## Overview

The app uses two state management approaches:

| Approach | Used For | Examples |
|----------|----------|----------|
| **Bloc** | Feature-specific, async-heavy, screen-scoped state | Listings, messaging, profile loading |
| **ChangeNotifier** | Global app-wide state, simple reactive values | Theme, language, auth status |

---

## When to Use Bloc

Use **Bloc** when:

- State is **tied to a specific screen or feature** (e.g. listing detail, chat, profile)
- You have **async operations** (API calls, loading, errors)
- You need **event-driven logic** (user actions → events → state changes)
- State has a **clear lifecycle** (created when screen opens, disposed when it closes)
- You want **BlocSelector** for granular rebuilds (see [BLOC_OPTIMIZATION_SUMMARY.md](BLOC_OPTIMIZATION_SUMMARY.md))

### Current Bloc Usage

| Bloc | Scope | Purpose |
|------|-------|---------|
| `ListingsBloc` | Home, search, user listings | Fetch/paginate listings |
| `MessagingBloc` | Chat, conversations, inbox | Messages and conversations |
| `CurrentUserProfileBloc` | Profile, burger menu, chat | Current user profile |
| `ListingDetailBloc` | Listing detail screen | Single listing details |
| `ListingOwnerProfileBloc` | Owner profile screen | Other user's profile |
| `LocationsBloc` | Search bottom sheet | Location search |
| `ComplaintBloc` | Complaint screens | Create/view complaints |

### Bloc Pattern

```dart
// Provide at screen level (or route level for shared state)
BlocProvider(
  create: (context) => SomeBloc(getIt<ISomeService>()),
  child: SomeScreen(),
)

// Consume with BlocSelector for performance
BlocSelector<SomeBloc, SomeState, _ScreenData>(
  selector: (state) => _ScreenData(...),
  builder: (context, data) => ...,
)
```

---

## When to Use ChangeNotifier

Use **ChangeNotifier** when:

- State is **global** and used across many unrelated screens
- State is **simple** (a few values, no complex async flows)
- You need a **singleton** that lives for the app lifetime
- Changes are **infrequent** (theme toggle, language switch, login/logout)

### Current ChangeNotifier Usage

| State | Purpose | Listeners |
|-------|---------|-----------|
| `ThemeState` | Light/blue theme selection | App bar, backgrounds, many screens |
| `LanguageState` | en/ru/uz language | L10n, all localized text |
| `AuthenticationState` | Logged in/out | Auth gate, messages refresh |
| `ProfileCompletionState` | Profile completion % | Profile screen, prompts |
| `UnreadMessagesState` | Unread count badge | Navigation bar, messages icon |
| `SearchFiltersState` | Search filter values | Search flow |

### ChangeNotifier Pattern

```dart
// Singleton factory (ThemeState, LanguageState)
class ThemeState extends ChangeNotifier {
  factory ThemeState() => _instance;
  ThemeState._internal();
  static final ThemeState _instance = ThemeState._internal();
  // ...
}

// Listen with ListenableBuilder
ListenableBuilder(
  listenable: ThemeState(),
  builder: (context, _) => Text(ThemeState().currentTheme),
)
```

---

## Decision Flowchart

```
New state to add?
│
├─ Is it global (theme, language, auth)?
│  └─ YES → Use ChangeNotifier (singleton)
│
├─ Is it screen/feature-specific with async (API, loading)?
│  └─ YES → Use Bloc
│
├─ Is it simple form state (no API)?
│  └─ Consider: local StatefulWidget state or Bloc
│
└─ Shared across multiple screens (e.g. messaging)?
   └─ Use Bloc + BlocProvider at route/app level
```

---

## Migration Notes (Future)

If you want to **unify on Bloc** for consistency:

1. **ThemeState → ThemeBloc**: Low effort, few listeners
2. **LanguageState → LanguageBloc**: Medium effort, L10n depends on it
3. **AuthenticationState → AuthBloc**: Medium effort, many listeners
4. **ProfileCompletionState, UnreadMessagesState**: Lower priority, fewer usages

Migration would improve consistency but is **optional**—the current split is intentional and works well.

---

## Related Docs

- [BLOC_OPTIMIZATION_SUMMARY.md](BLOC_OPTIMIZATION_SUMMARY.md) – BlocSelector usage and performance
- [README.md](README.md) – Architecture overview
