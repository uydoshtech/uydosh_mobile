/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

extension IterableExtension<E> on Iterable<E> {
  List<T> mapToList<T>(T Function(E e) toElement) => map(toElement).toList();

  List<E> whereToList(bool Function(E element) test) => where(test).toList();

  List<E>? get nullify => isEmpty ? null : toList();
}
