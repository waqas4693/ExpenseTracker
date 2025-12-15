import 'package:get/get.dart';

enum FilterType { today, thisWeek, thisMonth }

class FilterController extends GetxController {
  final Rx<FilterType> selectedFilter = FilterType.today.obs;

  void setFilter(FilterType filter) {
    selectedFilter.value = filter;
  }

  String getFilterLabel(FilterType filter) {
    switch (filter) {
      case FilterType.today:
        return 'Today';
      case FilterType.thisWeek:
        return 'This Week';
      case FilterType.thisMonth:
        return 'This Month';
    }
  }
}
