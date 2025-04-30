import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/game/models/shop_item.dart';
import 'package:flutter_application_2/game/widgets/menu_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../home/presentation/manager/user_cubit.dart';
import '../../../../home/presentation/manager/user_state.dart';

class InventoryUI extends StatefulWidget {
  final String? title;

  const InventoryUI({
    super.key,
    required this.title,
  });
  @override
  State<InventoryUI> createState() => _InventoryUIState();
}

class _InventoryUIState extends State<InventoryUI> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().getUserItems(widget.title?.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is InventoryLoaded) {
          return _buildUIContent(state.itemsList);
        }
        if (state is InventoryLoading) {
          return Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildUIContent(List<ShopItem>? itemsList) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: ColorManager.gunmetal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorManager.neonBlue, width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: ColorManager.neonBlue, width: 2),
                      ),
                    ),
                    child: Text(
                      widget.title!,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: itemsList!.isEmpty
                        ? const Center(
                            child: Text('No items',
                                style: TextStyle(color: Colors.white)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: itemsList.length,
                            itemBuilder: (c, i) {
                              final item = itemsList[i];
                              return Card(
                                color: Colors.grey.shade800,
                                child: ListTile(
                                  title: Text(item.name,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  subtitle: Text(item.description,
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  trailing: MenuButton(
                                      fontSize: 12,
                                      width: null,
                                      height: null,
                                      fillColor: ColorManager.primaryColor,
                                      buttonText: 'Equip',
                                      onPressed: () async {
                                        await context
                                            .read<UserCubit>()
                                            .equipItem(item.id, item.slot);
                                        if (mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      }),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: MenuButton(
                      fillColor: ColorManager.primaryColor,
                      buttonText: "Close Inventory",
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
