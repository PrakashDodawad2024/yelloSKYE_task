import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:yelloskye_task/controllers/project_controller.dart';
import 'package:yelloskye_task/models/project.dart';
import 'package:intl/intl.dart';
import 'package:yelloskye_task/utils/colors.dart';

class ChartsController extends GetxController {
  final ProjectController _projectController = Get.find<ProjectController>();

  RxList<FlSpot> projectsOverTimeData = <FlSpot>[].obs;

  RxList<BarChartGroupData> projectsByStatusData = <BarChartGroupData>[].obs;

  RxList<String> _sortedDaysForLineChart = <String>[].obs;

  final List<String> _projectStatuses = [
    'Planning',
    'In Progress',
    'Completed',
    'On Hold'
  ];

  @override
  void onInit() {
    super.onInit();

    ever(_projectController.projects, (_) {
      _generateChartData();
    });

    _generateChartData();
  }

  void _generateChartData() {
    final List<Project> projects = _projectController.projects;

    Map<String, int> projectsPerDay = {};
    for (var project in projects) {
      final String dayKey = DateFormat('yyyy-MM-dd').format(project.timestamp);
      projectsPerDay[dayKey] = (projectsPerDay[dayKey] ?? 0) + 1;
    }

    List<String> newSortedDays = projectsPerDay.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    List<FlSpot> newProjectsOverTimeData = [];
    for (int i = 0; i < newSortedDays.length; i++) {
      newProjectsOverTimeData.add(
          FlSpot(i.toDouble(), projectsPerDay[newSortedDays[i]]!.toDouble()));
    }
    projectsOverTimeData.value = newProjectsOverTimeData;
    _sortedDaysForLineChart.value = newSortedDays;

    Map<String, int> projectsCountByStatus = {};
    for (var status in _projectStatuses) {
      projectsCountByStatus[status] = 0;
    }

    for (var project in projects) {
      String status = project.status;
      if (!_projectStatuses.contains(status)) {
        status = 'Planning';
      }
      projectsCountByStatus[status] = (projectsCountByStatus[status] ?? 0) + 1;
    }

    List<BarChartGroupData> newProjectsByStatusData = [];
    for (int i = 0; i < _projectStatuses.length; i++) {
      String status = _projectStatuses[i];
      newProjectsByStatusData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: projectsCountByStatus[status]!.toDouble(),
              color: _getStatusColor(status),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    projectsByStatusData.value = newProjectsByStatusData;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Planning':
        return Colors.blue;
      case 'In Progress':
        return Colors.orangeAccent;
      case 'Completed':
        return Colors.green;
      case 'On Hold':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String getXAxisTitle(double value) {
    if (value.toInt() >= 0 && value.toInt() < _sortedDaysForLineChart.length) {
      return DateFormat('MMM dd')
          .format(DateTime.parse(_sortedDaysForLineChart[value.toInt()]));
    }
    return '';
  }

  String getStatusTitle(double value) {
    if (value.toInt() >= 0 && value.toInt() < _projectStatuses.length) {
      return _projectStatuses[value.toInt()];
    }
    return '';
  }
}
