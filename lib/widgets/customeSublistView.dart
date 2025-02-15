/*
* This is first step to 2nd list.
* This step is  used to loop the other steps and finaly navigate to the selling page or Tab view page
 *! ~2~
 */

import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/data/constants/converters/connectors.dart';
import 'package:aswenna/data/constants/converters/converters.dart';
import 'package:aswenna/widgets/sellinPage.dart';
import 'package:aswenna/widgets/tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomeSubListView extends StatefulWidget {
  final String listname, title, lan, mainName, mainNameE, firstLNameE;

  const CustomeSubListView({
    Key? key,
    required this.listname,
    required this.title,
    required this.lan,
    required this.mainName,
    required this.mainNameE,
    required this.firstLNameE,
  }) : super(key: key);

  @override
  State<CustomeSubListView> createState() =>
      _CustomeSubListViewState(listname: listname, lan: lan);
}

class _CustomeSubListViewState extends State<CustomeSubListView>
    with SingleTickerProviderStateMixin {
  final String listname, lan;
  late List<String> list;
  late List<String> EnList;
  var code;
  bool hasNextLevel = false;
  late AnimationController _controller;

  _CustomeSubListViewState({required this.listname, required this.lan}) {
    code = codeConverter(listname);
    list = subGridConnector(code, lan);
    EnList = subGridConnector(code, 'En');
    _checkNextLevel();
  }

  void _checkNextLevel() {
    for (var element in EnList) {
      var newcode = codeConverter(element);
      for (var paths in pathChangers) {
        if (paths == newcode) {
          hasNextLevel = true;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    print(
      "2nd Level: Title: ${widget.title} FirstNameE: ${widget.firstLNameE} lastName: ${widget.listname} maninNameE: ${widget.mainNameE}",
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.surface,
      iconTheme: const IconThemeData(color: AppColors.primary),
    );
  }

  Widget _buildBody() {
    if (list.isEmpty) {
      return CustomSellingPage(
        mainName: widget.mainName,
        firstLName: widget.title,
        lan: lan,
        secondLName: "list[index]",
        tabName: AppLocalizations.of(context)!.buying,
        secondLNameE: "EnList[index]",
        tabNameE: 'buying',
        mainNameE: widget.mainNameE,
        firstLNameE: widget.firstLNameE,
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildListItem(index),
    );
  }

  Widget _buildListItem(int index) {
    return Hero(
      tag: 'sublist-item-${EnList[index]}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shadowColor: AppColors.text.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleItemTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildIndexBadge(index),
                const SizedBox(width: 16),
                Expanded(child: _buildItemContent(index)),
                _buildNavigationIcon(index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndexBadge(int index) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildItemContent(int index) {
    bool hasSubItems = _checkHasSubItems(index);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          list[index],
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hasSubItems ? 'More categories inside' : 'View details',
          style: TextStyle(color: AppColors.textLight, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildNavigationIcon(int index) {
    bool hasSubItems = _checkHasSubItems(index);
    return Icon(
      hasSubItems ? Icons.chevron_right : Icons.arrow_forward_ios,
      size: hasSubItems ? 24 : 16,
      color: AppColors.primary.withValues(alpha: 0.7),
    );
  }

  bool _checkHasSubItems(int index) {
    var code = codeConverter(EnList[index]);
    return pathChangers.contains(code);
  }

  void _handleItemTap(int index) {
    bool hasSubItems = _checkHasSubItems(index);
    if (hasSubItems) {
      _navigateToSubList(index);
    } else {
      _navigateToTabView(index);
    }
  }

  void _navigateToSubList(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CustomeSubListView(
              mainName: widget.mainName,
              lan: widget.lan,
              listname: EnList[index],
              title: list[index],
              mainNameE: widget.mainNameE,
              firstLNameE: widget.firstLNameE,
            ),
      ),
    );
  }

  void _navigateToTabView(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CustomTabBar(
              tabNames: _getTabNames(index, context),
              tabWidgets: _buildTabWidgets(index, context),
              title: list[index],
            ),
      ),
    );
  }

  List<String> _getTabNames(int index, BuildContext context) {
    if (EnList[index] == 'Rent') {
      return [
        AppLocalizations.of(context)!.rentTabName1,
        AppLocalizations.of(context)!.rentTabName2,
      ];
    } else if (widget.mainNameE == 'labour') {
      return [
        AppLocalizations.of(context)!.labourTabName1,
        AppLocalizations.of(context)!.labourTabName2,
      ];
    }
    return [
      AppLocalizations.of(context)!.selling,
      AppLocalizations.of(context)!.buying,
    ];
  }

  List<Widget> _buildTabWidgets(int index, BuildContext context) {
    String tabName1 = _getTabName1(index, context);
    String tabName2 = _getTabName2(index, context);

    return [
      CustomSellingPage(
        mainName: widget.mainName,
        firstLName: widget.title,
        lan: widget.lan,
        secondLName: list[index],
        tabName: tabName1,
        secondLNameE: EnList[index],
        tabNameE: 'selling',
        mainNameE: widget.mainNameE,
        firstLNameE: widget.firstLNameE,
      ),
      CustomSellingPage(
        mainName: widget.mainName,
        firstLName: widget.title,
        lan: widget.lan,
        secondLName: list[index],
        tabName: tabName2,
        secondLNameE: EnList[index],
        tabNameE: 'buying',
        mainNameE: widget.mainNameE,
        firstLNameE: widget.firstLNameE,
      ),
    ];
  }

  String _getTabName1(int index, BuildContext context) {
    if (EnList[index] == 'Rent') {
      return AppLocalizations.of(context)!.rentTabName1;
    } else if (widget.mainNameE == 'labour') {
      return AppLocalizations.of(context)!.labourTabName1;
    }
    return AppLocalizations.of(context)!.selling;
  }

  String _getTabName2(int index, BuildContext context) {
    if (EnList[index] == 'Rent') {
      return AppLocalizations.of(context)!.rentTabName2;
    } else if (widget.mainNameE == 'labour') {
      return AppLocalizations.of(context)!.labourTabName2;
    }
    return AppLocalizations.of(context)!.buying;
  }
}
