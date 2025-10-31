/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

class PageableResponse<T> {
  PageableResponse({
    required this.data,
    required this.currentPage,
    required this.totalItems,
    required this.totalPages,
  });

  final List<T> data;

  final int currentPage;

  final int totalItems;

  final int totalPages;
}
