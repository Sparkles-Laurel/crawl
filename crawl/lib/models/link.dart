/// Contains classes for working with links.
library;

/// Represents a link on a web page.
class Link {
  /// The parent page of this link
  final Link? parent;
  /// The title of the link
  final String title;
  /// The address this link points to
  final Uri href;

  /// Instantiates a new link
  Link({required this.title, required this.href, this.parent});

  /// Returns the depth of this link.
  int get depth {
    var mDepth = 0;
    var mParent = parent;
    while (mParent != null) {
      mDepth++;
      mParent = mParent.parent;
    }

    return mDepth;
  }

  /// Returns the path used to access to this link.
  List<Link> get path {
    var mParent = parent;
    var mPath = <Link>[];
    while (mParent != null) {
      // TODO: add actual implementation.
    }

    return mPath;
  }
}