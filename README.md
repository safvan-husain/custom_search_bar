## customSearchBar

customSearchBar is a package that empowers you to have full control over both the search bar and app bar UI in your app's search screen. With customSearchBar, you can Effortlessly filter search results based on user input and preferences while customizing the app bar and search bar according to your preferences.

## Features

- **Customizable App Bar:** Enjoy complete control over the design of your app bar, making your search screen truly unique.
- **Refined Result Filtering:** Effortlessly filter search results based on user input and preferences.


## Default Screen build by the package
![alt taag](https://github.com/safvan-husain/custom_search_bar/blob/main/assets/search_screen.png)

## Installation

Add the following line to your `pubspec.yaml` file:

```yaml
dependencies:
  custom_search_bar: # Use the latest version
```

## Usage

### Import the package

```dart
import 'package:flutter/material.dart';
import 'package:custom_search_bar/custom_search_bar.dart';
```

### Basic example

the following will use default appBar and failure built by this package
use showSearchForCustomiseSearchDelegate function on a button, and it will open a search screen.

```dart

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PreferredSize(
          preferredSize: const Size(double.infinity, 50.0),
          child: AppBar(
            elevation: 0.0,
            title: const Text('Search Bar Without Customization'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  child: const Icon(Icons.search),
                  onTap: () => showSearchForCustomiseSearchDelegate<User>(
                    context: context,
                    backgroundColor:Colors.blue,
                    delegate: SearchScreen<User>(
                      itemStartsWith: true,
                      primaryColor:Colors.white,
                      seconderyColor:Colors.grey,
                      hintText: 'search here',
                      items: users,
                      filter: (user) => [user.name],
                      itemBuilder: (user) => ListTile(title: Text(user)),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: const Center(
        child: Text('The body.'),
      ),
    );
  }
}

```

### Implement the CustomSearchBar

Built the AppBar the way want, `AppBar` widget is not necessary.
provide the `appBarBuilder` parameters to the `TextField`

```dart

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PreferredSize(
          preferredSize: const Size(double.infinity, 50.0),
          child: AppBar(
            elevation: 0.0,
            title: const Text('Search Bar With Customization'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  child: const Icon(Icons.search),
                  onTap: () => showSearchForCustomiseSearchDelegate<User>(
                    context: context,
                    delegate: SearchScreen<User>(
                      itemStartsWith: true,
                      hintText: 'search here',
                      items: users,
                      filter: (user) => [user.name],
                      itemBuilder: (user) => ListTile(title: Text(user.name)),
                      failure: const Center(
                        child: Text('no items found'),
                      ),
                      appBarBuilder: (
                        controller,
                        onSubmitted,
                        textInputAction,
                        focusNode,
                      ) {
                        return PreferredSize(
                          preferredSize: const Size(double.infinity, 50),
                          child: AppBar(
                            title: TextField(
                              controller: controller,
                              onSubmitted: onSubmitted,
                              textInputAction: textInputAction,
                              focusNode: focusNode,
                            ),
                            actions: [
                              InkWell(
                                onTap: () => onSubmitted(controller.text),
                                child: const Icon(Icons.search),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: const Center(
        child: Text('The body.'),
      ),
    );
  }
}
```

## Issues and Contributions

Please feel free to [report any issues or bugs](https://github.com/safvan-husain/custom_search_bar/issues) you encounter. Contributions and pull requests are also welcome!

## License

This package is open-source and available under the MIT License.

```

```

```

```
