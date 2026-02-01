// ignore_for_file: prefer_const_constructors

import 'package:aswenna/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final List<String> tabNames;
  final List<Widget> tabWidgets;
  final String title;

  const CustomTabBar({
    Key? key,
    required this.tabNames,
    required this.tabWidgets,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabNames.length,
      child: Scaffold(appBar: _buildAppBar(context), body: _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // Debug: tab bar data logged
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      iconTheme: IconThemeData(color: AppColors.surface),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.surface,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            border: Border(
              bottom: BorderSide(
                color: AppColors.surface.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            unselectedLabelColor: AppColors.surface.withValues(alpha: 0.7),
            labelColor: AppColors.surface,
            tabs: _buildTabs(),
            labelPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTabs() {
    return tabNames.map((name) => _buildTab(name)).toList();
  }

  Widget _buildTab(String name) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(letterSpacing: 0.3),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              children:
                  tabWidgets
                      .map(
                        (widget) => Container(
                          padding: EdgeInsets.all(16),
                          child: widget,
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
