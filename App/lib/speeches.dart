class Speeches {
  int id;
  String title;
  String content;

  Speeches(this.id, this.title, this.content);

    Map toJson() => {
      'id': id,
      'title': title,
      'content': content
    };
  }