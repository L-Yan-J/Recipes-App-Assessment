class RecipeModel {
  String image;
  String name;
  String type;
  String ingredients;
  String step;
  String id;

  RecipeModel(
      {this.image = "",
      this.name = "",
      this.type = "",
      this.ingredients = "",
      this.step = "",
      required this.id});
}
