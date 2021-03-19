animagus_assi:
  type: assignment
  debug: false
  actions:
    on assignment:
    - trigger name:damage state:true
    - trigger name:click state:true
    - trigger name:death state:true
    - trigger name:proximity state:true radius:3
    - vulnerable state:true
    on spawn:
    - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
    on despawn:
    - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
    # sentinel setup
    on damage:
    - narrate "tier hp: <npc.health>"
    - inject playerform
    on death:
    - if <npc.has_flag[loot]>:
      - drop <npc.flag[loot]> <npc.location>
    # TODO: better solution for respawning dead npcs?
    - wait 360
    - if <npc.has_flag[spawn]>:
      - spawn <npc> <npc.flag[spawn]>
    - else:
      - DEBUG ERROR "Tier ohne Spawnpunkt: <npc>"
    on click:
    # Mit Wurfnetz fangen
    - narrate "klick"
    - inject tierform
    on enter proximity:
    - inject playerform
    # on exit proximity:
    # - if <npc.entity_type> == PLAYER:
    #   - announce "<gray> Debug: player exit"
    #   - playeffect at:<npc.location.sub[0.1,0,0]> effect:CLOUD quantity:8 offset:0.2,0.2,0.2
    #   - execute as_server "npc type <npc.flag[tier]> --id <npc.id>"
      # - execute as_server "sentinel remtarget player --id <npc.id>" silent


playerform:
  type: task
  script:
    - narrate "Task on <npc>"
    - if <npc.entity_type> == <npc.flag[tier]>:
      - narrate surprise
      - wait 0.2
      - playeffect at:<npc.location.sub[0.1,0,0]> effect:CLOUD quantity:8 offset:0.2,0.2,0.2
      - execute as_server "npc type player --id <npc.id>"
      - execute as_server "sentinel addtarget player --id <npc.id>" silent


tierform:
  type: task
  script:
    - if <npc.entity_type> == PLAYER:
      - playeffect at:<npc.location.sub[0.1,0,0]> effect:CLOUD quantity:8 offset:0.2,0.2,0.2
      - execute as_server "npc type <npc.flag[tier]> --id <npc.id>"
      - execute as_server "sentinel removetarget player --id <npc.id>" silent


animagus_cmd:
    type: command
    name: npcanimagus
    usage: /npcanimagus
    dscription: Manage Animagus
    tab complete:
    - define args1 <list[neu|info|loot|hilfe]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    - else if <context.args.get[1]> == neu:
        - define args2 <list[wolf|fuchs|schwein|katze|VANILLA_TYPE]>
        - if !<[args2].contains[<context.args.get[2]||null>]>:
            - determine <[args2]>

    script:
    - if !<player.is_op||context.server>:
        - narrate "<red> Keine Berechtigung."
        - stop
    - if !<list[neu|info|loot].contains[<context.args.get[1]||null>]>:
        - narrate <yellow>-----------------------------
        - narrate "<yellow>/npcanimagus info"
        - narrate "  <gray>- Zeigt Infos zum ausgewählten animagus."
        - narrate "<yellow>/npcanimagus neu <white>[TYPE]"
        - narrate "  <gray>- Erstellt ein passives animagus (minecraft AI)"
        - narrate "<yellow>/npcanimagus hilfe"
        - narrate "  <gray>- Zeigt diese Hilfe an"
        - narrate "<yellow>/npcanimagus loot"
        - narrate "  <gray>- DIESER animagus dropt das Item (in Hand halten)"
        - narrate <yellow>-----------------------------
        - stop

    # Info des NPC vorlesen
    - if <context.args.get[1]> == info:
      - narrate "TODO: stats anzeigen"

    - if <context.args.get[1]> == neu:
        # - if !<list[tropenfisch|fuchs].contains[<context.args.get[2]>]>:
        #     - narrate "<red>Ungültiger animagustyp: <yellow>/npcmonster neu <red>[TYPE]"
        - if <context.args.get[2]> == wolf:
            - define type WOLF
        - else if <context.args.get[2]> == fuchs:
            - define type FOX
        - else if <context.args.get[2]> == katze:
            - define type CAT
        - else if <context.args.get[2]> == schwein:
            - define type PIG
        - else if <context.args.get[2]> == spinne:
            - define type SPIDER
        - else:
            - narrate "<red>Unbekannter Typ: <gray>Versuche NPC mit type <context.args.get[2]> zu erstellen"
            - define type <context.args.get[2]||player>
        # monster erstellen
        - create <[type]> <[type]> <player.location> save:npc
        - define npc <entry[npc].created_npc>
        - adjust <player> selected_npc:<[npc]>
        - assignment set script:animagus_assi npc:<[npc]>
        - trait state:true sentinel to:<[npc]>
        # - adjust <[npc]> has_ai:true
        # - adjust <[npc]> swimming:<[swimming]||true>
        # - execute as_player  "npc swim"
        # - execute as_player "npc ai"
        - execute as_player "npc name"
        - flag <[npc]> spawn:<[npc].location>
        - flag <[npc]> tier:<[type]>
        - execute as_server "wp provider wander --id <[npc].id>"
        - adjust <npc> add_waypoint:<npc.location>
        - adjust <npc> range:9
        - execute as_server "sentinel health 30 --id <[npc].id>" silent
        - execute as_server "sentinel damage 3 --id <[npc].id>" silent
        # - execute as_server "sentinel attackrate <[attackrate]||1> --id <[npc].id>" silent
        # - execute as_server "sentinel healrate <[healrate]||1> --id <[npc].id>" silent
        # - execute as_server "sentinel attackrate <[attackrate]||3> --id <[npc].id>" silent
        - execute as_server "sentinel respawntime <[respawntime]||60> --id <[npc].id>" silent
        - execute as_server "sentinel spawnpoint --id <[npc].id>" silent
        # - execute as_server "sentinel addtarget player --id <[npc].id>" silent
        - execute as_server "sentinel removeignore owner --id <[npc].id>" silent
        - narrate "<green>animagus erstellt"
        - stop

    - if <context.args.get[1]> == loot:
        - flag <player.selected_npc> loot:<player.item_in_hand>
        - narrate "<green>Loot gegeben: <player.item_in_hand>"