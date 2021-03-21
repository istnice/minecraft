dungeon_cmd:
    type: command
    name: dim
    usage: /dim
    description: manage dimensions
    tab complete:
    - define args1 <list[create|list|help|info|join]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    # - if <list[create].contains[<context.args.get[1]>]>:
    - define create_raw_args "create "
    - if <context.raw_args.starts_with[<[create_raw_args]>]>:
        - if <context.args.get[2]||null> == null:
            - determine <list[NAME]>
        - else:
            - determine <list[COPYOF]>
    - else if <list[join]>:
        - determine <server.flag[dims].keys>
    script:
    - inject permission_op
    - if !<list[create|help||info|join|setup].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/dim info <light_purple>(SPIELER)"
        - narrate "  <gray>- Zeigt info zum aktuellen Dungeon. Optional: Von angegebenem Spieler"
        - narrate "<yellow>/dim list"
        - narrate "  <gray>- Listet alle eingetragenen Dungeon"
        - narrate "<yellow>/dim join <light_purple>NAME"
        - narrate "  <gray>- tritt der dimension bei (als flag ohne tp)"
        - narrate <gray>-----------------------------
        - stop
    - if <context.args.get[1]> == create:
        - narrate "Neue Dimension erstellen"
        - if <context.args.get[2]> == world:
            - narrate "<red>Uff das war knapp, da hättest du fast, die Welt gelöscht.."
            - stop
        - if <context.args.get[2].starts_with[dim_]>:
            - define dim_name <context.args.get[2]>
        - else:
            - define dim_name dim_<context.args.get[2]||unnamed>
        - if <server.has_flag[dims.<[dim_name]>]>:
            - narrate "<red>Dimension mit diesem Namen existiert bereits, abgebrochen.."
            - stop
        - define dim_copy <context.args.get[3]||superflat>
        - define dim_start <location[0,100,0,0,0,<[dim_name]>]>
        - define dim_finish <player.location>
        # notables for tpin and tpout has to be set (names are dim_tpin_NAME)
        # TODO check dimname exist in flag and in notables/world file -> warnings
        - define dim_data <map[name/<[dim_name]>|start/<[dim_start]>|finish/<[dim_finish]>]>
        - flag server dims.<[dim_name]>:<[dim_data]>
        - flag <player> selected_dim:<[dim_name]>
        - ~createworld <[dim_name]> copy_from:<[dim_copy]>
        - teleport <player> <[dim_start]>
        - stop
    - if <context.args.get[1]> == setup:
        - if !<list[tpin|tpout|start|finish].contains[<context.args.get[2]>]>:
            - narrate <gray>-----------------------------
            - narrate "<yellow>/dim setup tpin"
            - narrate "  <gray>- Aktuelle WorldEdit selection (//pos1 - //pos2) als Eingangsportal"
            - narrate "<yellow>/dim setup tpout"
            - narrate "  <gray>- Aktuelle WorldEdit selection (IN DIM) als Ausgangsportal"
            - narrate "<yellow>/dim setup start"
            - narrate "  <gray>- Aktuelle Position (IN DIM) als Startpunkt"
            - narrate "<yellow>/dim setup finish"
            - narrate "  <gray>- Aktuelle Position (world) als Rückportpunkt"
            - narrate <gray>-----------------------------
            - stop
        - if !<player.has_flag[selected_dim]>:
            - narrate "<red>Fehler:<gray> Keine Dimension ausgewählt. Versuche <yellow>/dim select <light_purple>NAME"
            - stop
        - define dim <player.flag[selected_dim]>
        - choose <context.args.get[2]>:
            - case tpin:
                - if <player.we_selection||null> == null:
                    - narrate "<red>Fehler:<gray> Keine WorldEdit Selection. Markiere Ecken mit <yellow>//pos1 <gray> und <yellow>//pos2<gray>."
                    - stop
                - note <player.we_selection> as:tpin_<[dim]>
            - case tpout:
                - if <player.we_selection||null> == null:
                    - narrate "<red>Fehler:<gray> Keine WorldEdit Selection. Markiere Ecken mit <yellow>//pos1 <gray> und <yellow>//pos2<gray>."
                    - stop
                - note <player.we_selection> as:tpout_<[dim]>
            - case start:
                - flag server dims.<[dim]>.start:<player.location>
            - case finish:
                - flag server dims.<[dim]>.finish:<player.location>
        - stop


dim_world:
    type: world
    events:
        on player enters cuboid:
        - if <context.area.note_name.starts_with[tpin_dim_]>:
            - define dim_name <context.area.note_name.substring[6]>
            # - narrate "Teleport ins Dungeon: <[dim_name]>"
            - define start <server.flag[dims.<[dim_name]>].get[start]>
            # - narrate "start pos: <[start]>"
            - teleport <player> <[start]>
        - if <context.area.note_name.starts_with[tpout_dim_]>:
            - define dim_name <context.area.note_name.substring[7]>
            - define finish <server.flag[dims.<[dim_name]>].get[finish]>
            - teleport <player> <[finish]>
            # - narrate "Teleport ausm Dungeon"