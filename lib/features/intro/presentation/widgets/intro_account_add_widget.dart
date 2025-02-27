// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';

// Project imports:
import 'package:paisa/config/routes.dart';
import 'package:paisa/core/common.dart';
import 'package:paisa/core/enum/card_type.dart';
import 'package:paisa/core/widgets/paisa_widget.dart';
import 'package:paisa/features/account/data/data_sources/account_data_source.dart';
import 'package:paisa/features/account/data/data_sources/default_account.dart';
import 'package:paisa/features/account/data/model/account_model.dart';
import 'package:paisa/features/intro/presentation/widgets/intro_image_picker_widget.dart';
import 'package:paisa/main.dart';

class IntroAccountAddWidget extends StatefulWidget {
  const IntroAccountAddWidget({
    super.key,
  });

  @override
  State<IntroAccountAddWidget> createState() => _IntroAccountAddWidgetState();
}

class _IntroAccountAddWidgetState extends State<IntroAccountAddWidget>
    with AutomaticKeepAliveClientMixin {
  final AccountDataSource dataSource = getIt<AccountDataSource>();
  final List<AccountModel> defaultModels = defaultAccountsData();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PaisaAnnotatedRegionWidget(
      color: context.background,
      child: Scaffold(
        body: ValueListenableBuilder<Box<AccountModel>>(
          valueListenable: getIt<Box<AccountModel>>().listenable(),
          builder: (context, value, child) {
            final List<AccountModel> categoryModels = value.values.toList();
            return ListView(
              children: [
                IntroTopWidget(
                  title: context.loc.addAccount,
                  icon: Icons.credit_card_outlined,
                ),
                Builder(
                  builder: (context) {
                    return ScreenTypeLayout.builder(
                      mobile: (p0) => PaisaFilledCard(
                        child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              Divider(color: Theme.of(context).dividerColor),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryModels.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final AccountModel model = categoryModels[index];
                            return AccountItemWidget(
                              model: model,
                              onPress: () async {
                                await model.delete();
                                defaultModels.add(model);
                              },
                            );
                          },
                        ),
                      ),
                      tablet: (p0) => GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250,
                          childAspectRatio: 2,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryModels.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final AccountModel model = categoryModels[index];
                          return AccountItemWidget(
                            model: model,
                            onPress: () async {
                              await model.delete();
                              defaultModels.add(model);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    context.loc.recommendedAccounts,
                    style: context.titleMedium,
                  ),
                ),
                Builder(builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16,
                    ),
                    child: Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: [
                        ...defaultModels
                            .sorted((a, b) => a.name.compareTo(b.name))
                            .map((model) => FilterChip(
                                  onSelected: (value) {
                                    dataSource.add(model.copyWith(
                                        name: settings.get(
                                      userNameSetKey,
                                      defaultValue: model.name,
                                    )));
                                    setState(() {
                                      defaultModels.remove(model);
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    side: BorderSide(
                                      color: context.primary,
                                    ),
                                  ),
                                  showCheckmark: false,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  label: Text(model.bankName),
                                  labelStyle: context.titleMedium,
                                  padding: const EdgeInsets.all(12),
                                  avatar: Icon(
                                    model.cardType.icon,
                                    color: context.primary,
                                  ),
                                )),
                        FilterChip(
                          onSelected: (value) {
                            const AccountPageData().push(context);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                            side: BorderSide(
                              color: context.primary,
                            ),
                          ),
                          showCheckmark: false,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          label: Text(context.loc.addAccount),
                          labelStyle: context.titleMedium,
                          padding: const EdgeInsets.all(12),
                          avatar: Icon(
                            Icons.add_rounded,
                            color: context.primary,
                          ),
                        )
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AccountItemWidget extends StatelessWidget {
  const AccountItemWidget({
    super.key,
    required this.model,
    required this.onPress,
  });

  final AccountModel model;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(model.color);
    return ScreenTypeLayout.builder(
      mobile: (p0) => ListTile(
        onTap: onPress,
        leading: Icon(
          model.cardType.icon,
          color: color,
        ),
        title: Text(model.bankName),
        subtitle: Text(model.name),
        trailing: Icon(MdiIcons.delete),
      ),
      tablet: (p0) => PaisaCard(
        child: InkWell(
          onTap: onPress,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    model.cardType.icon,
                    color: color,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: context.titleMedium,
                      ),
                      Text(
                        model.bankName,
                        style: context.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
