import '../models/character.dart';
import '../models/shop_item.dart';

class ItemEffectResult {
  final bool success;
  final String message;
  final Character updatedCharacter;

  ItemEffectResult({
    required this.success,
    required this.message,
    required this.updatedCharacter,
  });
}

class ItemService {
  ItemEffectResult applyItemEffect(Character character, ShopItem item) {
    print('ItemService: Applying item effect for ${item.name}');
    print(
        'ItemService: Initial player HP: ${character.currentHp}/${character.vitality}');

    // Create a copy of the character to modify
    Character updatedCharacter = character;
    String resultMessage = '';
    bool success = false;

    // Apply different effects based on item effects map
    if (item.effects.isNotEmpty) {
      print(
          'ItemService: Item has ${item.effects.length} effects: ${item.effects}');

      // Convert all keys to lowercase for case-insensitive matching
      Map<String, int> normalizedEffects = {};
      item.effects.forEach((key, value) {
        normalizedEffects[key.toLowerCase()] = value;
      });

      print('ItemService: Normalized effects: $normalizedEffects');

      // Process health restoration (handling both vitality and health keys)
      if (normalizedEffects.containsKey('vitality') ||
          normalizedEffects.containsKey('health') ||
          normalizedEffects.containsKey('health_restore')) {
        // Find the correct healing value, prioritizing specific health keys
        final int healAmount = normalizedEffects['health_restore'] ??
            normalizedEffects['health'] ??
            normalizedEffects['vitality'] ??
            0;

        print('ItemService: Processing health restore of $healAmount');

        if (character.currentHp < character.vitality) {
          final newHp =
              (character.currentHp + healAmount).clamp(0, character.vitality);
          final actualHeal = newHp - character.currentHp;

          updatedCharacter = character.copyWith(currentHp: newHp);
          resultMessage = 'Restored $actualHeal health.';
          success = true;
          print(
              'ItemService: Healed for $actualHeal. New HP: ${updatedCharacter.currentHp}/${updatedCharacter.vitality}');
        } else {
          resultMessage = 'Already at full health!';
          print('ItemService: Already at full health');
          return ItemEffectResult(
            success: false,
            message: resultMessage,
            updatedCharacter: character,
          );
        }
      }

      // Process temporary stat boosts
      final statBoosts = <String, int>{};

      normalizedEffects.forEach((key, value) {
        if (key == 'strength' || key == 'strength_boost') {
          statBoosts['strength'] = value;
        } else if (key == 'endurance' || key == 'endurance_boost') {
          statBoosts['endurance'] = value;
        } else if (key == 'agility' || key == 'agility_boost') {
          statBoosts['agility'] = value;
        } else if (key == 'vitality_boost') {
          // Only treat as max vitality boost if explicitly named vitality_boost
          statBoosts['vitality'] = value;
          // If vitality increases, also increase current HP
          final vitalityIncrease = value;
          final newHp = updatedCharacter.currentHp + vitalityIncrease;
          updatedCharacter = updatedCharacter.copyWith(currentHp: newHp);
        }
      });

      // Apply stat boosts if any exist
      if (statBoosts.isNotEmpty) {
        print('ItemService: Applying stat boosts: $statBoosts');
        updatedCharacter = updatedCharacter.copyWith(
          strength: statBoosts.containsKey('strength')
              ? updatedCharacter.strength + statBoosts['strength']!
              : updatedCharacter.strength,
          endurance: statBoosts.containsKey('endurance')
              ? updatedCharacter.endurance + statBoosts['endurance']!
              : updatedCharacter.endurance,
          agility: statBoosts.containsKey('agility')
              ? updatedCharacter.agility + statBoosts['agility']!
              : updatedCharacter.agility,
          vitality: statBoosts.containsKey('vitality')
              ? updatedCharacter.vitality + statBoosts['vitality']!
              : updatedCharacter.vitality,
        );

        // Add stat boost info to the message
        final statMessages = <String>[];
        for (final stat in statBoosts.entries) {
          statMessages.add('${_formatStatName(stat.key)} +${stat.value}');
        }

        if (resultMessage.isNotEmpty) {
          resultMessage += ' ';
        }
        resultMessage += 'Temporary boost: ${statMessages.join(', ')}.';
        success = true;
      }
    }

    if (!success) {
      // Default message if no specific effects were applied
      resultMessage = 'Used ${item.name}.';
      success = true;
    }

    print(
        'ItemService: Final result - success: $success, message: $resultMessage');
    print(
        'ItemService: Final player stats: HP ${updatedCharacter.currentHp}/${updatedCharacter.vitality}, STR ${updatedCharacter.strength}, END ${updatedCharacter.endurance}, AGI ${updatedCharacter.agility}');

    return ItemEffectResult(
      success: success,
      message: resultMessage,
      updatedCharacter: updatedCharacter,
    );
  }

  String _formatStatName(String stat) {
    return stat
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }
}
