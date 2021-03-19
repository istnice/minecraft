tier_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:damage state:true
        - trigger name:click state:true
        - trigger name:death state:true
        - vulnerable state:true
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
        # sentinel setup
        on damage:
        - narrate "tier hp: <npc.health>"
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
        - if <player.item_in_hand.display> == Wurfnetz:
            - take bydisplay:Wurfnetz from:<player.inventory>
            - playsound <player> sound:ENTITY_CREEPER_DEATH
            - playsound <player> sound:ENTITY_SLIME_ATTACK
            - playeffect at:<npc.location.sub[0.1,0,0]> effect:CLOUD quantity:8 offset:0.2,0.2,0.2
            - define imnetz <item[netz_item]>
            - define iname "Netz (<npc.name>)"
            - adjust def:imnetz display:<[iname]>
            - drop <[imnetz]> <npc.location>
            - despawn <npc>
            # respawn delayed
            - wait 360
            - if <npc.has_flag[spawn]>:
                - spawn <npc> <npc.flag[spawn]>
            - else:
                - announce "<red>Tier ohne Spawnpunkt: <npc>"

netz_item:
    type: item
    material: bone_meal
    display name: Netz


tier_cmd:
    type: command
    name: npctier
    usage: /npctier
    dscription: "Spawnt und managed Tiere. Tiere haben Minecraft AI und sind passiv. Loot und Respawnzeit können konfiguriert werden."
    tab complete:
    - define args1 <list[neu|info|loot|hilfe]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    - else if <context.args.get[1]> == neu:
        - define args2 <list[tropenfisch|fuchs|schwein|katze|VANILLA_TYPE]>
        - if !<[args2].contains[<context.args.get[2]||null>]>:
            - determine <[args2]>

    script:
    - if !<player.is_op||context.server>:
        - narrate "<red> Keine Berechtigung."
        - stop
    - if !<list[neu|info|loot].contains[<context.args.get[1]||null>]>:
        - narrate <yellow>-----------------------------
        - narrate "<yellow>/npctier info"
        - narrate "  <gray>- Zeigt Infos zum ausgewählten Tier."
        - narrate "<yellow>/npctier neu <white>[TYPE]"
        - narrate "  <gray>- Erstellt ein passives tier (minecraft AI)"
        - narrate "<yellow>/npctier hilfe"
        - narrate "  <gray>- Zeigt diese Hilfe an"
        - narrate "<yellow>/npctier loot"
        - narrate "  <gray>- Tier Dropt das Item (in Hand halten)"
        - narrate <yellow>-----------------------------
        - stop

    # Info des NPC vorlesen
    - if <context.args.get[1]> == info:
      - narrate "TODO: stats anzeigen"

    - if <context.args.get[1]> == neu:
        # - if !<list[tropenfisch|fuchs].contains[<context.args.get[2]>]>:
        #     - narrate "<red>Ungültiger Tiertyp: <yellow>/npcmonster neu <red>[TYPE]"
        - if <context.args.get[2]> == tropenfisch:
            - define type tropical_fish
            - define swimming false
        - else if <context.args.get[2]> == fuchs:
            - define type fox
        - else if <context.args.get[2]> == katze:
            - define type cat
        - else if <context.args.get[2]> == schwein:
            - define type pig
        - else:
            - narrate "<red>Unbekannter Typ: <gray>Versuche NPC mit type <context.args.get[2]> zu erstellen"
            - define type <context.args.get[2]||player>
        # monster erstellen
        - create <[type]> <[type]> <player.location> save:npc
        - define npc <entry[npc].created_npc>
        - adjust <player> selected_npc:<[npc]>
        - assignment set script:tier_assi npc:<[npc]>
        # - adjust <[npc]> has_ai:true
        # - adjust <[npc]> swimming:<[swimming]||true>
        - execute as_player  "npc swim"
        - execute as_player "npc ai"
        - execute as_player "npc name"
        - flag <[npc]> spawn:<[npc].location>
        - narrate "<green>Tier erstellt"
        - stop

    - if <context.args.get[1]> == loot:
        - flag <player.selected_npc> loot:<player.item_in_hand>
        - narrate "<green>Loot gegeben: <player.item_in_hand>"
