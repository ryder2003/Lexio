class AdhdImage {
  final String imageUrl;
  final String caption;

  AdhdImage({
    required this.imageUrl,
    required this.caption,
  });

  factory AdhdImage.fromJson(Map<String, dynamic> json) {
    return AdhdImage(
      imageUrl: json['imageUrl'],
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    'caption': caption,
  };
}