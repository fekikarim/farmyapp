class FarmGrid {
  final String landId;
  final int width;
  final int height;
  final List<List<FarmCell?>> matrix;

  FarmGrid({
    required this.landId,
    required this.width,
    required this.height,
    required this.matrix,
  });

  factory FarmGrid.fromJson(Map<String, dynamic> json) {
    final List<dynamic> matrixJson = json['matrix'] ?? [];
    
    List<List<FarmCell?>> matrix = [];
    for (var rowJson in matrixJson) {
      List<FarmCell?> row = [];
      for (var cellJson in rowJson) {
        if (cellJson == null) {
          row.add(null);
        } else {
          row.add(FarmCell.fromJson(cellJson));
        }
      }
      matrix.add(row);
    }

    return FarmGrid(
      landId: json['land_id'] ?? '',
      width: json['grid_width'] ?? 0,
      height: json['grid_height'] ?? 0,
      matrix: matrix,
    );
  }
}

class FarmCell {
  final String id;
  final String category;
  final String variantId;
  final String variantCode;

  FarmCell({
    required this.id,
    required this.category,
    required this.variantId,
    required this.variantCode,
  });

  factory FarmCell.fromJson(Map<String, dynamic> json) {
    return FarmCell(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      variantId: json['variant_id'] ?? '',
      variantCode: json['variant_code'] ?? '',
    );
  }
}
