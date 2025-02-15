class FirestorePaths {
  static const String items = 'items';

  static String getItemPath(List<String> pathSegments) {
    // If path segments count is even, we need to add 'items' collection
    // Because Firestore needs to alternate between collections and documents
    if (pathSegments.length % 2 == 0) {
      return [...pathSegments, 'items'].join('/');
    }
    // If odd, return as is because it already ends in a collection
    return pathSegments.join('/');
  }
}
