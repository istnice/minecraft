check_recipes:
    type: world
    events:
        on item recipe formed:
        - narrate "<blue>TODO: <gray>check spieler hat rezept: <context.inventory.recipe>"


rezepte_cmd:
    type: command
    name: rezepte
    usage: /rezepte
    description: rezepte von spielern verwalten
    script:
    - inject permission_op
    - if !<list[neu|info|loot].contains[<context.args.get[1]||null>]>:
        - narrate <yellow>-----------------------------
        - narrate "<yellow>/rezepte info"
        - narrate "  <gray>- Zeigt Infos zum ausgewählten animagus."
        - narrate "<yellow>/rezepte add <white>[TYPE]"
        - narrate "  <gray>- Erstellt ein passives animagus (minecraft AI)"
        - narrate "<yellow>/rezepte rem"
        - narrate "  <gray>- DIESER animagus dropt das Item (in Hand halten)"
        - narrate "<yellow>/rezepte hilfe"
        - narrate "  <gray>- Zeigt diese Hilfe an"
        - narrate <yellow>-----------------------------
        - stop