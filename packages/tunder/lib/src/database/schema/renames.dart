class Rename {
  final String from;
  final String to;

  Rename(this.from, this.to);
}

class RenameColumn extends Rename {
  RenameColumn(String from, String to) : super(from, to);
}

class RenameIndex extends Rename {
  RenameIndex(String from, String to) : super(from, to);
}

class RenamePrimary extends Rename {
  RenamePrimary(String from, String to) : super(from, to);
}
