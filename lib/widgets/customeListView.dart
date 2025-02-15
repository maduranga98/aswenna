// ignore_for_file: file_names

/*
* This is the main grid. This from home page to first step
  *! ~1~
 */
// title-> main page name
// listname -> first level list name
// lan -> language
// userAppBar -> to remove or add the appBar
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/data/constants/converters/connectors.dart';
import 'package:aswenna/widgets/customeSublistView.dart';
import 'package:aswenna/widgets/sellinPage.dart';
import 'package:flutter/material.dart';

class CustomeListView extends StatefulWidget {
  final String listname, title, lan, titleE;
  final bool useAppBar;

  const CustomeListView({
    Key? key,
    required this.listname,
    required this.useAppBar,
    required this.title,
    required this.lan,
    required this.titleE,
  }) : super(key: key);

  @override
  State<CustomeListView> createState() =>
      _CustomeListViewState(listname: listname, lan: lan);
}

class _CustomeListViewState extends State<CustomeListView>
    with SingleTickerProviderStateMixin {
  final String listname, lan;
  late List<String> list;
  late List<String> enList;
  late AnimationController _controller;

  _CustomeListViewState({required this.listname, required this.lan}) {
    list = mainGridConnector(listname, lan);
    enList = mainGridConnector(listname, 'en');
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    print(
      "1st level: Title: ${widget.title} LastName: ${widget.listname} titleE:${widget.titleE} ",
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
      appBar: widget.useAppBar ? _buildAppBar() : null,
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
        mainName: widget.title,
        firstLName: '',
        secondLName: '',
        lan: lan,
        tabName: '',
        mainNameE: widget.titleE,
        firstLNameE: '',
        secondLNameE: '',
        tabNameE: '',
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
      tag: 'list-item-${enList[index]}',
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
          onTap: () => _navigateToDetail(index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildIndexBadge(index),
                const SizedBox(width: 16),
                Expanded(child: _buildItemContent(index)),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
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
          'Tap to explore more',
          style: TextStyle(color: AppColors.textLight, fontSize: 12),
        ),
      ],
    );
  }

  void _navigateToDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CustomeSubListView(
              listname: enList[index],
              title: list[index],
              lan: lan,
              mainName: widget.title,
              mainNameE: widget.titleE,
              firstLNameE: enList[index],
            ),
      ),
    );
  }
}
