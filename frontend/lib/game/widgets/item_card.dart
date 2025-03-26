import 'package:flutter/material.dart';

import '../../core/theme/color_manger.dart';
import '../../core/theme/text_style.dart';
import '../../core/utils/app_icons.dart';
import '../viewmodel/shop_view_model.dart';
import 'menu_button.dart';

class ItemCard extends StatefulWidget {
  final dynamic item;
  final ShopViewModel viewModel;
  const ItemCard({super.key, this.item, required this.viewModel});

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorManager.gunmetal,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.name,
                style: TextStyles.styleSemiBold(context,
                    fontSize: 24, color: ColorManager.whiteColor)),
            Text('${widget.item.description}',
                style: TextStyles.styleMedium(context,
                    fontSize: 16, color: ColorManager.whiteColor)),
            MenuButton(
                fillColor: ColorManager.primaryColor,
                iconColor: ColorManager.lightGreen,
                buttonText: "${widget.item.price}",
                onPressed: () {
                  widget.viewModel.buyItem(widget.item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Purchased ${widget.item.name}')),
                  );
                },
                buttonIcon: AppIcons.coinsIcon)
          ],
        ),
      ),
    );
  }
}
