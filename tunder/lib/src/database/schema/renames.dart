class Rename {
  final String from;
  final String to;

  const Rename(this.from, this.to);
}

class RenameColumn extends Rename {
  const RenameColumn(String from, String to) : super(from, to);
}

class RenameIndex extends Rename {
  const RenameIndex(String from, String to) : super(from, to);
}

class RenamePrimary extends Rename {
  const RenamePrimary(String from, String to) : super(from, to);
}
