class ArticleModel {
  String? title, language, category, thumb_id, description, article_id, thumb;
  List<String> tags;
  ArticleModel(
      {required this.title,
      required this.language,
      required this.category,
      required this.thumb_id,
      required this.description,
      required this.article_id,
      required this.thumb,
      required this.tags});
}
