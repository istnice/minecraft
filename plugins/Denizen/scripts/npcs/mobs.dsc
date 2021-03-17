monster_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:damage state:true
        - trigger name:click state:true
        - trigger name:death state:true
        # sentinel setup
        on damage:
        - narrate "monster hp: <npc.health>"
        on death:
        # - narrate "monster tot"
        - if <npc.has_flag[loot]>:
            # - narrate "loot gefunden"
            - drop <npc.flag[loot]>
            # - flag <player> schweineloot:--

monster_cmd:
    type: command
    name: npcmonster
    usage: /npcmonster [NEU/] ([WOLF/BAER/SPINNE/GIFTSPINNE])
    dscription: "Spawnt und managed monster. Monster haben das Sentinel Combat-System und sind aggressiv gegen Spieler."
      # You can optionally specify tab completions on a per-argument basis.
    # Available context:
    # <context.args> returns a list of input arguments.
    # <context.raw_args> returns all the arguments as raw text.
    # <context.server> returns whether the server is using tab completion (a player if false).
    # <context.alias> returns the command alias being used.
  # | This key is great to have when used well, but is not required.
    # You can also optionally use the 'tab complete' key to build custom procedure-style tab complete logic
    # if the simply numeric argument basis isn't sufficient.
    # Has the same context available as 'tab completions'.
    # | Most scripts should leave this key off, though it can be useful to some.
    tab complete:
    - define args1 <list[neu|info|loot|hilfe]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    - else if <context.args.get[1]> == neu:
        - define args2 <list[wolf|spinne|ertrunkener]>
        - if !<[args2].contains[<context.args.get[2]||null>]>:
            - determine <[args2]>

    script:
    - if !<list[neu|info|loot].contains[<context.args.get[1]||null>]>:
        - narrate <yellow>-----------------------------
        - narrate "<yellow>/npcmonster info"
        - narrate "  <gray>- Zeigt Infos zum ausgewählten monster."
        - narrate "<yellow>/npcmonster neu <white>[TYPE]"
        - narrate "  <gray>- Erstellt ein aggressives monster"
        - narrate "<yellow>/npcmonster hilfe"
        - narrate "  <gray>- Zeigt diese Hilfe an"
        - narrate "<yellow>/npcmonster loot"
        - narrate "  <gray>- NPC Dropt das Item (in Hand halten)"
        - narrate <yellow>-----------------------------
        - stop

    # Info des NPC vorlesen
    - if <context.args.get[1]> == info:
      - narrate "TODO: stats anzeigen"

    - if <context.args.get[1]> == neu:
        # fallback values
        - define level <context.args.get[3]||5>
        - define respawntime 60
        - if !<list[wolf|spinne|ertrunkener].contains[<context.args.get[2]>]>:
            - narrate "<red>Ungültiger Monstertyp: <yellow>/npcmonster neu <red>[TYPE]"
        - else if <context.args.get[2]> == wolf:
            # wolf spezifisch
            - define type wolf
            - define health <[level].mul[2].add[12]>
            - define damage <[level].div[2]>
            - define healrate <[level].div[10]>
            - define attackrate 1
            - define wander 10
            # TODO: is this set by npc tag "range"? or only x/yrange in path editor? for now default config values used
        - else if <context.args.get[2]> == spinne:
            - define type spider
            - define wander 5
        - else if <context.args.get[2]> == ertrunkener:
            - define type drowned
            - define wander 3
        # monster erstellen
        - create <[type]> "<[type]> (<[level]>)" <player.location> save:npc traits:sentinel
        - define npc <entry[npc].created_npc>
        - adjust <player> selected_npc:<[npc]>
        - assignment set script:monster_assi npc:<[npc]>
        # pathfinding
        - if <[wander]||0> > 0:
            - execute as_server "wp provider wander --id <[npc].id>"
            - adjust <npc> add_waypoint:<npc.location>
            - adjust <npc> range:9
            # - execute as_player:<player> "wp provider wander"
        # sentinel stats
        - execute as_server "sentinel health <[health]||40> --id <[npc].id>" silent
        - execute as_server "sentinel damage <[damage]||3> --id <[npc].id>" silent
        - execute as_server "sentinel attackrate <[attackrate]||1> --id <[npc].id>" silent
        - execute as_server "sentinel healrate <[healrate]||1> --id <[npc].id>" silent
        - execute as_server "sentinel attackrate <[attackrate]||3> --id <[npc].id>" silent
        - execute as_server "sentinel respawntime <[respawntime]||60> --id <[npc].id>" silent
        - execute as_server "sentinel spawnpoint --id <[npc].id>" silent
        - execute as_server "sentinel addtarget player --id <[npc].id>" silent
        - execute as_server "sentinel removeignore owner --id <[npc].id>" silent
        - narrate "<green>Monster erstellt"
        - stop

    - if <context.args.get[1]> == loot:
        - flag <player.selected_npc> loot:<player.item_in_hand>
        - narrate "<green>Loot gegeben: <player.item_in_hand>"
