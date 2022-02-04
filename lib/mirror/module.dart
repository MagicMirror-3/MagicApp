class Module {
  Module(
      {required this.name,
      this.description,
      this.image = "no_image.png",
      this.config = "{}"});

  final String name;
  final String? description;
  final String image;
  final String config;
}
