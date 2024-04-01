import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef SearchFilter<T> = List<String?> Function(T t);

Future<T?> showSearchForCustomiseSearchDelegate<T>({
  required BuildContext context,
  required SearchDelegate<T> delegate,
  Color? backgroundColor,
  String? query = '',
  bool useRootNavigator = false,
}) {
  delegate.query = query ?? delegate.query;
  delegate._currentBody = _SearchBody.suggestions;
  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push(_SearchPageRoute<T>(
    delegate: delegate,
    backgroundColor: backgroundColor,
  ));
}

class SearchScreen<T> extends SearchDelegate<T> {
  /// Method that returns the specific parameters intrinsic
  /// to a [T] instance.
  ///
  /// For example, filter a person by its name & age parameters:
  /// filter: (person) => [
  ///   person.name,
  ///   person.age.toString(),
  /// ]
  ///
  /// All parameters to filter through must be [String] instances.
  final SearchFilter<T> filter;
  final List<T> items;
  final bool itemStartsWith;
  final bool itemEndsWith;
  final Widget Function(T t) itemBuilder;
  final BoxDecoration? searchBarDecration;
  final Color? primaryColor;
  final Color? seconderyColor;
  final String? hintText;
  final Widget? cancelWidget;

  ///Use the provided parameters [ controller, onSubmitted ] to the TextField.
  ///
  final PreferredSize Function(
    TextEditingController controller,
    dynamic Function(String?) onSubmitted,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
  )? appBarBuilder;
  final Widget failure;
  SearchScreen({
    this.hintText,
    this.primaryColor,
    this.seconderyColor,
    this.searchBarDecration,
    this.cancelWidget,
    required this.items,
    required this.filter,
    this.itemStartsWith = false,
    this.itemEndsWith = false,
    required this.itemBuilder,
    this.failure = const Center(
      child: Text('No such item'),
    ),
    this.appBarBuilder,
  }) : super(
          searchFieldLabel: hintText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );
  @override
  PreferredSizeWidget? buildAppBar({
    required context,
    required TextEditingController controller,
    FocusNode? focusNode,
    TextStyle? style,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
    required Function(String? text) onSubmitted,
  }) {
    if (appBarBuilder != null) {
      return appBarBuilder!(
          controller, onSubmitted, textInputAction, focusNode);
    } else {
      return PreferredSize(
        preferredSize: const Size(double.infinity, 60.0),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: searchBarDecration ??
                        BoxDecoration(
                          color: primaryColor ??
                              Theme.of(context).primaryColorLight,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              left: 10,
                            ),
                            child: TextField(
                              focusNode: focusNode,
                              controller: controller,
                              textInputAction: textInputAction,
                              keyboardType: TextInputType.text,
                              onSubmitted: onSubmitted,
                              decoration: InputDecoration(
                                hintText: hintText ?? 'search here',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                            onTap: () => onSubmitted(controller.text),
                            child: const Hero(
                                tag: 'icon', child: Icon(Icons.search)))
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    if (controller.text == "") {
                      Navigator.of(context).pop();
                    } else {
                      controller.text = "";
                    }
                  },
                  child: cancelWidget ??
                      CircleAvatar(
                        backgroundColor: Colors.black12,
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: CircleAvatar(
                            backgroundColor: primaryColor ??
                                Theme.of(context).primaryColorLight,
                            child: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    // Deletes possible blank spaces & converts the string to lower case
    final cleanQuery = query.toLowerCase().trim();

    // Using the [filter] method, filters through the [items] list
    // in order to select matching items
    final result = items
        .where(
          // First we collect all [String] representation of each [item]
          (item) => filter(item)
              // Then, transforms all results to lower case letters
              .map((value) => value?.toLowerCase().trim())
              // Finally, checks wheters any coincide with the cleaned query
              // Checks wheter the [startsWith] or [endsWith] are 'true'
              .any((value) => _filterByValue(query: cleanQuery, value: value)),
        )
        .toList();

    if (result.isEmpty) return failure;

    return ListView.builder(
      itemCount: result.length,
      itemBuilder: (context, index) {
        return itemBuilder(result.elementAt(index));
      },
    );
  }

  bool _filterByValue({
    required String query,
    required String? value,
  }) {
    if (value == null) {
      return false;
    }
    if (itemStartsWith && itemEndsWith) {
      return value == query;
    }
    if (itemStartsWith) {
      return value.startsWith(query);
    }
    if (itemEndsWith) {
      return value.endsWith(query);
    }
    return value.contains(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Deletes possible blank spaces & converts the string to lower case
    final cleanQuery = query.toLowerCase().trim();

    // Using the [filter] method, filters through the [items] list
    // in order to select matching items
    final result = items
        .where(
          // First we collect all [String] representation of each [item]
          (item) => filter(item)
              // Then, transforms all results to lower case letters
              .map((value) => value?.toLowerCase().trim())
              // Finally, checks wheters any coincide with the cleaned query
              // Checks wheter the [startsWith] or [endsWith] are 'true'
              .any((value) => _filterByValue(query: cleanQuery, value: value)),
        )
        .toList();

    if (result.isEmpty) return failure;

    return ListView.builder(
      itemCount: result.length,
      itemBuilder: (context, index) {
        return itemBuilder(result.elementAt(index));
      },
    );
  }
}

abstract class SearchDelegate<T> {
  SearchDelegate({
    this.searchFieldLabel,
    this.searchFieldStyle,
    this.searchFieldDecorationTheme,
    this.keyboardType,
    this.textInputAction = TextInputAction.search,
  }) : assert(searchFieldStyle == null || searchFieldDecorationTheme == null);

  Widget buildSuggestions(BuildContext context);

  Widget buildResults(BuildContext context);

  Widget? buildLeading(BuildContext context) => null;

  List<Widget>? buildActions(BuildContext context) => null;

  PreferredSizeWidget? buildBottom(BuildContext context) => null;

  PreferredSizeWidget? buildAppBar({
    required context,
    required TextEditingController controller,
    FocusNode? focusNode,
    TextStyle? style,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
    required void Function(String?) onSubmitted,
  });

  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      ),
      inputDecorationTheme: searchFieldDecorationTheme ??
          InputDecorationTheme(
            hintStyle: searchFieldStyle ?? theme.inputDecorationTheme.hintStyle,
            border: InputBorder.none,
          ),
    );
  }

  /// The current query string shown in the [AppBar].
  ///
  /// The user manipulates this string via the keyboard.
  ///
  /// If the user taps on a suggestion provided by [buildSuggestions] this
  /// string should be updated to that suggestion via the setter.
  String get query => _queryTextController.text;

  /// Changes the current query string.
  ///
  /// Setting the query string programmatically moves the cursor to the end of the text field.
  set query(String value) {
    _queryTextController.text = value;
    if (_queryTextController.text.isNotEmpty) {
      _queryTextController.selection = TextSelection.fromPosition(
          TextPosition(offset: _queryTextController.text.length));
    }
  }

  /// Transition from the suggestions returned by [buildSuggestions] to the
  /// [query] results returned by [buildResults].
  ///
  /// If the user taps on a suggestion provided by [buildSuggestions] the
  /// screen should typically transition to the page showing the search
  /// results for the suggested query. This transition can be triggered
  /// by calling this method.
  ///
  /// See also:
  ///
  ///  * [showSuggestions] to show the search suggestions again.
  void showResults(BuildContext context) {
    _focusNode?.unfocus();
    _currentBody = _SearchBody.results;
  }

  /// Transition from showing the results returned by [buildResults] to showing
  /// the suggestions returned by [buildSuggestions].
  ///
  /// Calling this method will also put the input focus back into the search
  /// field of the [AppBar].
  ///
  /// If the results are currently shown this method can be used to go back
  /// to showing the search suggestions.
  ///
  /// See also:
  ///
  ///  * [showResults] to show the search results.
  void showSuggestions(BuildContext context) {
    assert(_focusNode != null,
        '_focusNode must be set by route before showSuggestions is called.');
    _focusNode!.requestFocus();
    _currentBody = _SearchBody.suggestions;
  }

  /// Closes the search page and returns to the underlying route.
  ///
  /// The value provided for `result` is used as the return value of the call
  /// to [showSearch] that launched the search initially.
  void close(BuildContext context, T result) {
    _currentBody = null;
    _focusNode?.unfocus();
    Navigator.of(context)
      ..popUntil((Route<dynamic> route) => route == _route)
      ..pop(result);
  }

  /// The hint text that is shown in the search field when it is empty.
  ///
  /// If this value is set to null, the value of
  /// `MaterialLocalizations.of(context).searchFieldLabel` will be used instead.
  final String? searchFieldLabel;

  /// The style of the [searchFieldLabel].
  ///
  /// If this value is set to null, the value of the ambient [Theme]'s
  /// [InputDecorationTheme.hintStyle] will be used instead.
  ///
  /// Only one of [searchFieldStyle] or [searchFieldDecorationTheme] can
  /// be non-null.
  final TextStyle? searchFieldStyle;

  /// The [InputDecorationTheme] used to configure the search field's visuals.
  ///
  /// Only one of [searchFieldStyle] or [searchFieldDecorationTheme] can
  /// be non-null.
  final InputDecorationTheme? searchFieldDecorationTheme;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to the default value specified in [TextField].
  final TextInputType? keyboardType;

  /// The text input action configuring the soft keyboard to a particular action
  /// button.
  ///
  /// Defaults to [TextInputAction.search].
  final TextInputAction textInputAction;

  /// [Animation] triggered when the search pages fades in or out.
  ///
  /// This animation is commonly used to animate [AnimatedIcon]s of
  /// [IconButton]s returned by [buildLeading] or [buildActions]. It can also be
  /// used to animate [IconButton]s contained within the route below the search
  /// page.
  Animation<double> get transitionAnimation => _proxyAnimation;

  // The focus node to use for manipulating focus on the search page. This is
  // managed, owned, and set by the _SearchPageRoute using this delegate.
  FocusNode? _focusNode;

  final TextEditingController _queryTextController = TextEditingController();

  final ProxyAnimation _proxyAnimation =
      ProxyAnimation(kAlwaysDismissedAnimation);

  final ValueNotifier<_SearchBody?> _currentBodyNotifier =
      ValueNotifier<_SearchBody?>(null);

  _SearchBody? get _currentBody => _currentBodyNotifier.value;
  set _currentBody(_SearchBody? value) {
    _currentBodyNotifier.value = value;
  }

  _SearchPageRoute<T>? _route;
}

/// Describes the body that is currently shown under the [AppBar] in the
/// search page.
enum _SearchBody {
  /// Suggested queries are shown in the body.
  ///
  /// The suggested queries are generated by [SearchDelegate.buildSuggestions].
  suggestions,

  /// Search results are currently shown in the body.
  ///
  /// The search results are generated by [SearchDelegate.buildResults].
  results,
}

class _SearchPageRoute<T> extends PageRoute<T> {
  _SearchPageRoute({
    required this.delegate,
    required this.backgroundColor,
  }) {
    assert(
      delegate._route == null,
      'The ${delegate.runtimeType} instance is currently used by another active '
      'search. Please close that search by calling close() on the SearchDelegate '
      'before opening another search with the same delegate instance.',
    );
    delegate._route = this;
  }

  final SearchDelegate<T> delegate;
  final Color? backgroundColor;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => false;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Animation<double> createAnimation() {
    final Animation<double> animation = super.createAnimation();
    delegate._proxyAnimation.parent = animation;
    return animation;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _SearchPage<T>(
      delegate: delegate,
      animation: animation,
      backgroundColor: backgroundColor,
    );
  }

  @override
  void didComplete(T? result) {
    super.didComplete(result);
    assert(delegate._route == this);
    delegate._route = null;
    delegate._currentBody = null;
  }
}

class _SearchPage<T> extends StatefulWidget {
  const _SearchPage({
    required this.delegate,
    required this.animation,
    required this.backgroundColor,
  });

  final SearchDelegate<T> delegate;
  final Animation<double> animation;
  final Color? backgroundColor;

  @override
  State<StatefulWidget> createState() => _SearchPageState<T>();
}

class _SearchPageState<T> extends State<_SearchPage<T>> {
  // This node is owned, but not hosted by, the search page. Hosting is done by
  // the text field.
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.delegate._queryTextController.addListener(_onQueryChanged);
    widget.animation.addStatusListener(_onAnimationStatusChanged);
    widget.delegate._currentBodyNotifier.addListener(_onSearchBodyChanged);
    focusNode.addListener(_onFocusChanged);
    widget.delegate._focusNode = focusNode;
  }

  @override
  void dispose() {
    super.dispose();
    widget.delegate._queryTextController.removeListener(_onQueryChanged);
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    widget.delegate._currentBodyNotifier.removeListener(_onSearchBodyChanged);
    widget.delegate._focusNode = null;
    focusNode.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    if (widget.delegate._currentBody == _SearchBody.suggestions) {
      focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(_SearchPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      oldWidget.delegate._queryTextController.removeListener(_onQueryChanged);
      widget.delegate._queryTextController.addListener(_onQueryChanged);
      oldWidget.delegate._currentBodyNotifier
          .removeListener(_onSearchBodyChanged);
      widget.delegate._currentBodyNotifier.addListener(_onSearchBodyChanged);
      oldWidget.delegate._focusNode = null;
      widget.delegate._focusNode = focusNode;
    }
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus &&
        widget.delegate._currentBody != _SearchBody.suggestions) {
      widget.delegate.showSuggestions(context);
    }
  }

  void _onQueryChanged() {
    setState(() {
      // rebuild ourselves because query changed.
    });
  }

  void _onSearchBodyChanged() {
    setState(() {
      // rebuild ourselves because search body changed.
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final ThemeData theme = widget.delegate.appBarTheme(context);
    final String searchFieldLabel = widget.delegate.searchFieldLabel ??
        MaterialLocalizations.of(context).searchFieldLabel;
    Widget? body;
    switch (widget.delegate._currentBody) {
      case _SearchBody.suggestions:
        body = KeyedSubtree(
          key: const ValueKey<_SearchBody>(_SearchBody.suggestions),
          child: widget.delegate.buildSuggestions(context),
        );
        break;
      case _SearchBody.results:
        body = KeyedSubtree(
          key: const ValueKey<_SearchBody>(_SearchBody.results),
          child: widget.delegate.buildResults(context),
        );
        break;
      case null:
        break;
    }

    late final String routeName;
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        routeName = '';
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        routeName = searchFieldLabel;
    }

    return Semantics(
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: routeName,
      child: Theme(
        data: theme,
        // child: Column(
        //   children: [
        //     Container(
        //       color: Colors.red,
        //       width: double.infinity,
        //       height: 400,
        //     ),
        //     AnimatedSwitcher(
        //       duration: const Duration(milliseconds: 300),
        //       child: body,
        //     )
        //   ],
        // ),

        child: Scaffold(
          backgroundColor: widget.backgroundColor,
          appBar: widget.delegate.buildAppBar(
            context: context,
            controller: widget.delegate._queryTextController,
            focusNode: focusNode,
            style:
                widget.delegate.searchFieldStyle ?? theme.textTheme.titleLarge,
            textInputAction: widget.delegate.textInputAction,
            keyboardType: widget.delegate.keyboardType,
            onSubmitted: (String? _) {
              widget.delegate.showResults(context);
            },
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: body,
          ),
        ),
      ),
    );
  }
}
