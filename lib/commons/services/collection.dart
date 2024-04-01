class CollectionService {
  static List<T> getRandomSublist<T>(List<T> referenceList, int length) {
    return ([...referenceList]..shuffle()).sublist(0, length);
  }

  static List<T> getListsDifference<T>(List<T> first, List<T> last) {
    return (first.toSet()..removeAll(last)).toList();
  }
}
