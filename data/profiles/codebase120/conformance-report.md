# Conformance Report — impact

0 / 1 capabilities GREEN

| Capability | Status | Detail |
|---|---|---|
| `harness.liveness` — Game-thread dispatch | 🔒 BLOCKED | GameThread.ensure timed out — harness cannot read game state on this build |

## Outstanding

- **harness.liveness** (BLOCKED): GameThread.ensure timed out — harness cannot read game state on this build

## Autonomous digest sweep

Attempted 0 unresolved field(s) beyond the capability slice; committed 0 (confidence-gated, ≥90/100 — not oracle-validated).

## Mapping inventory — all digest fields

71 / 193 logical fields have a confirmed mapping.

Narrowed to candidates, awaiting confirmation (5):

- **Player**: Player.id, animation
- **Projectile**: Projectile.x, y, z

No mapping at all (117):

- **Widget**: Widget.children, dynamicChildren, staticChildren, nestedChildren, childIds, childXOffsets, childYOffsets, scrollHeight, scrollX, scrollY, width, relativeX, spriteId, animationId, opacity
- **Client**: Client.widget, widgetRoots, openInterfaceId, walkableInterfaceId, inventoryOverlayInterfaceId, chatboxInterfaceId, tabRootWidgetIds
- **Scene**: Scene.tiles
- **Tile**: Tile.gameObjects, wallObject, decorativeObject, groundObject, groundItems, worldLocation, localLocation
- **TileObject**: TileObject.id, worldLocation, localLocation
- **GameObject**: GameObject.sceneMinLocation, sceneMaxLocation
- **ObjectComposition**: ObjectComposition.impostorIds, varbitId, varpId
- **Client**: Client.scene, objectDefinition
- **NPC**: NPC.name, worldLocation, dead, interacting, composition, transformedComposition
- **NPCComposition**: NPCComposition.combatLevel, standAnimation, walkAnimation
- **Client**: Client.cachedNPCs, npcIndices
- **Player**: Player.worldLocation, poseAnimation, idlePoseAnimation, skullIcon
- **Actor**: Actor.interacting
- **Client**: Client.localPlayerIndex, localPlayerId, itemContainer
- **ItemContainer**: ItemContainer.items, stackSizes, count
- **Item**: Item.id, quantity
- **ItemComposition**: ItemComposition.note, noteTemplate
- **Client**: Client.itemDefinition, itemContainer
- **ItemContainer**: ItemContainer.items
- **Item**: Item.id, quantity
- **ItemComposition**: ItemComposition.equipmentSlot
- **EquipmentInventorySlot**: EquipmentInventorySlot.HEAD, WEAPON, SHIELD, BODY, LEGS
- **Widget**: Widget.children
- **Client**: Client.itemContainer, widget, invokeMenuAction, menuEntries
- **MenuEntry**: MenuEntry.option, target, identifier, type, param0, param1
- **Client**: Client.varpValue, varbitValue, boostedSkillLevel, realSkillLevel, skillExperience, weight, gameCycle, baseY, graphicsObjects, projectiles
- **GraphicsObject**: GraphicsObject.location, animationId, z
- **Widget**: Widget.children, dynamicChildren
- **Client**: Client.widget
- **Actor**: Actor.interacting
- **Client**: Client.varpValue, varbitValue, widget, boostedSkillLevel, realSkillLevel
- **Widget**: Widget.spriteId
- **Tile**: Tile.groundItems, worldLocation, localLocation
- **TileItem**: TileItem.id, quantity
- **Client**: Client.scene
