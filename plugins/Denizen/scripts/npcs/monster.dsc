monster_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:damage state:true
        - trigger name:click state:true
        - trigger name:death state:true
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
        # sentinel setup
        on damage:
            - flag <npc> last_loc:<npc.location>
        on death:
        # - narrate "monster tot"
        # custom loot at player
        - if <npc.has_flag[loot]>:
            # - narrate "loot gefunden"
            - drop <npc.flag[loot]> <npc.flag[last_loc]||<player.location>>
            - stop
        # type based loot
        - else:
            - define lvl <npc.flag[level]||0>
            - define typ <npc.flag[type]||null>
            - define loottable <server.flag[monster].get[<[typ]>].get[loot]||null>
            - if <[loottable]> == null:
                - announce "<red>Loot Fehlt NPC-<npc.id>): <gray>nichts eingetragen, weder speziell für diesen mob (/npcmonster loot) noch für monster alg: (data/monster.yml)"
                - stop
            - if <[loottable].contains[epic]> && <util.random.int[1].to[100]> < 3:
                - foreach <[loottable].get[epic]> as:drop:
                    - drop <item[<[drop].get[item]>]> <npc.flag[last_loc]||<player.location>> quantity:<[drop].get[quantity]||1>
            - if <[loottable].contains[fix]>:
                - foreach <[loottable].get[fix]> as:drop:
                    - narrate "DROP fix: <[drop]>"
                    - drop <item[<[drop].get[item]>]> <npc.flag[last_loc]||<player.location>> quantity:<[drop].get[quantity]||1>
            - if <[loottable].contains[scaling]>:
                - narrate "drop scaling"
                - foreach <[loottable].get[scaling]> as:drop:
                    - define lvl_count <npc.flag[level]||1>
                    - while <[lvl_count]> > 0:
                        - define lvl_count <[lvl_count].sub_int[1]>
                        - if <util.random.int[1].to[100]> <= <[drop].get[chance]||0>:
                            - drop <item[<[drop].get[item]>]> <npc.flag[last_loc]||<player.location>>
                # - narrate "TODO: LEVEL SCALING LOOT"



monster_cmd:
    type: command
    debug: false
    name: npcmonster
    usage: /npcmonster
    description: "Spawnt und managed monster. Monster haben das Sentinel Combat-System und sind aggressiv gegen Spieler."
    tab complete:
    - define args1 <list[neu|info|loot|hilfe|laden|update|resetall]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    - else if <context.args.get[1]> == neu:
        - define args2 <server.flag[monster].keys>
        - if !<[args2].contains[<context.args.get[2]||null>]>:
            - determine <[args2]>

    script:
    # | CHECK
    - inject permission_op
    - if !<list[neu|info|loot|update|laden|level|resetall].contains[<context.args.get[1]||null>]>:
        - narrate <yellow>-----------------------------
        - narrate "<yellow>/npcmonster info"
        - narrate "  <gray>- Zeigt Infos zum ausgewählten monster."
        - narrate "<yellow>/npcmonster neu <light_purple>TYPE"
        - narrate "  <gray>- Erstellt ein aggressives monster"
        - narrate "<yellow>/npcmonster hilfe"
        - narrate "  <gray>- Zeigt diese Hilfe an"
        - narrate "<yellow>/npcmonster loot"
        - narrate "  <gray>- NPC Dropt das Item (in Hand halten)"
        - narrate "<yellow>/npcmonster laden"
        - narrate "  <gray>- Lädt monster und stats aus datei neu"
        - narrate "<yellow>/npcmonster level <light_purple>LEVEL"
        - narrate "  <gray>- Passt das level eines monsters an.."
        - narrate "<yellow>/npcmonster resetall"
        - narrate "  <gray>- Reload und Respawn alle monster (wie bei server neustart)"
        - narrate <yellow>-----------------------------
        - stop
    # | INFO
    - if <context.args.get[1]> == info:
      - narrate "TODO: stats anzeigen"
    - else if <context.args.get[1]> == update:
        - if <player.selected_npc> != null:
            - run update_monster_task def:<player.selected_npc>
    # | NEU
    - if <context.args.get[1]> == neu:
        - if !<server.flag[monster].keys.contains[<context.args.get[2]>]>:
            - narrate "<red>Ungültiger Monstertyp: <yellow>/npcmonster neu <red>TYPE"
            - stop
        - define type <server.flag[monster].get[<context.args.get[2]>].get[vanilla].get[type]>
        # - narrate <[type]>
        - define level:<context.args.get[3]||1>
        - create <[type]> "<[type]> (<[level]>)" <player.location> save:npc traits:sentinel
        - define npc <entry[npc].created_npc>
        - adjust <player> selected_npc:<[npc]>
        - flag <[npc]> level:<[level]>
        - flag <[npc]> type:<[type]>
        - assignment set script:monster_assi npc:<[npc]>
        - run update_monster_task def:<[npc]>
        - execute as_server "sentinel spawnpoint --id <[npc].id>" silent
        - execute as_server "wp provider wander --id <[npc].id>"
        - adjust <[npc]> add_waypoint:<[npc].location>
        - adjust <[npc]> range:9
    # | LOOT
    - if <context.args.get[1]> == loot:
        - flag <player.selected_npc> loot:<player.item_in_hand>
        - narrate "<green>Loot gegeben: <player.item_in_hand>"
    # | resetall
    - if <context.args.get[1]> == resetall:
        - run monster_reset_task


update_monster_task:
    type: task
    debug: false
    definitions: npc
    script:
    # fallback flags
    - if !<[npc].has_flag[level]>:
        - flag <[npc]> level:1
    - if !<[npc].has_flag[type]>:
        - flag <[npc]> type:wolf
    # variables
    - define level <[npc].flag[level]>
    - define type <[npc].flag[type]>
    - define mon <server.flag[monster].get[<[type]>]>
    # combat stats (general)
    - execute as_server "sentinel addtarget player --id <[npc].id>" silent
    - execute as_server "sentinel removeignore owner --id <[npc].id>" silent
    # scaling values
    - define stats <map>
    # - narrate "updating from <[mon]>"
    - if <[mon].contains[sentinel_scaling]>:
        # - narrate "scaling values gefunden"
        - foreach <[mon].get[sentinel_scaling]> key:k as:coefs:
            - define n 0
            - define result 0
            # TODO: does key:idx as:value also work for lists to return the loop counter?
            - foreach <[coefs]> as:c:
                - define term <[c].mul[<[level].power[<[n]>]>]>
                # - narrate "<gray><[level]>^<[n]> * <[c]>= <[term]>"
                - define result <[result].add[<[term]>]>
                - define n <[n].add[1]>
            # - narrate "<black><[k]>: <[result]>"
            - define stats <[stats].with[<[k]>].as[<[result]>]>
    # fix values
    - foreach <[mon].get[sentinel]> key:k as:stat:
        # - narrate "<dark_gray><[k]>: <[stat]>"
        - define stats <[stats].with[<[k]>].as[<[stat]>]>
    # apply combat stats
    - foreach <[stats]> key:k as:stat:
        # - narrate "<dark_green>APPLY SENTINEL: <[k]> = <[stat]>"
        - execute as_server "sentinel <[k]> <[stat]> --id <[npc].id>" silent

    # pathfinding
    # TODO: is this set by npc tag "range"? or only x/yrange in path editor? for now default config values used
    # - if <[wander]||0> > 0:

    # TODO: type injections


monster_laden_task:
    type: task
    debug: false
    script:
    - yaml create id:monster
    - yaml load:data/monster.yml id:monster
    - flag server monster:<yaml[monster].read[monster]>
    - yaml unload id:monster
    # - announce "Monster geladen"


monster_reset_task:
    type: task
    debug: false
    script:
    - foreach <server.npcs_assigned[monster_assi]> as:npc:
        - execute as_server "sentinel respawn --id <[npc].id>" silent
        - execute as_server "sentinel forgive --id <[npc].id>" silent
        - run update_monster_task def:<[npc]>


# TODO: copy egg (spawnt copy von selected npc mit selben flags usw.. )

monster_world:
    type: world
    debug: false
    events:
        on reload scripts:
        - run monster_laden_task
        on server start:
        - inject monster_laden_task
        - run monster_reset_task
        on player right clicks block with:monsterspawn_item:
        - inject permission_op
        - define type <context.item.flag[monstertype]>
        - define level <context.item.quantity||1>
        - define cmd "npcmonster neu <[type]> <[level]>"
        - narrate "<dark_gray>Spawnei führt Befehl aus: <gray>/<[cmd]>"
        - execute as_player <[cmd]>
        # - define data <server.flag[monster].get[<[type]>]||null>


monsterspawn_item:
  type: item
  material: wolf_spawn_egg
  display name: Monster - (unknown)
  flags:
    monstertype: unknown