quest_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:proximity state:true radius:10
        - sneak <npc> start fake
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
        on enter proximity:
        - if <player.flag[quests.fertig].contains[<npc.flag[quests.quests].get[1]>]>:
            - determine cancelled
        - flag <npc> dampf:true duration:30
        - while <player.is_online> && <npc.has_flag[dampf]>:
          - playeffect effect:CLOUD at:<npc.location.add[0,2.5,0]> quantity:1 offset:0
          - wait 1
        on leave proximity:
        - flag <npc> dampf:!
        on click:
        # - playeffect effect:VILLAGER_HAPPY location:<npc.location>
        # check requirements
        - if <npc.has_flag[quester.ruf]>:
            - define nruf <npc.flag[quester.ruf.wert]||null>
            - define pruf <player.flag[ruf.<npc.flag[quester.ruf.gilde]>]||0>
            - if <[nruf]> > <[pruf]> || <[nruf]>==null:
                - narrate "<red>Nicht genug Ruf<gray> um mit diesem NPC zu reden! <[pruf]>/<[nruf]>"
                - determine cancelled
        - flag <player> quester.npc:<npc> duration:120s
        - define book <item[buch_item]>
        # load quest:
        - define qid <npc.flag[quests.quests].get[1]>
        - define quest <server.flag[quests].get[<[qid]>]||null>
        - if <[quest]> == null:
            - narrate "Quest nicht gefunden: <[qid]>"
            - stop
        - define qname <[quest].get[name]>
        # - define state <player.flag[quest.<[qid]>.state]||null>
        - if <player.flag[quests.aktiv].keys.contains[<[qid]>]>:
            - define seite <[quest].get[wait]>
        - else if <player.flag[quests.fertig].keys.contains[<[qid]>]>:
            - define seite <[quest].get[done]>
        - else:
            - define antwort "<blue>⚜ <[quest].get[answ].on_click[/quests start <[qid]>]>"
            - define seite <[quest].get[desc]><p><[antwort]>
        - adjust def:book book_pages:<list[<[seite]>|]>
        - adjust <player> show_book:<[book]>
        - determine cancelled


npcquest_cmd:
    type: command
    name: npcquest
    usage: /npcquest
    description: assigns quest and sets flags
    debug: false
    tab complete:
    - define args1 <list[neu|ruf|link|hilfe]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    - else if <context.args.get[1]> == neu:
        - determine <list[NAME]>
    - else if <context.args.get[1]> == link:
        - determine <server.flag[quests].keys>
    script:
    # check commands
    - if !<list[neu|ruf|text|antwort|link].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/npcquest neu <white>[NAME]"
        - narrate "  <gray>- Erstellt NPC der Quest startet"
        - narrate "<yellow>/npcquest ruf <white>[GILDE] [MENGE]"
        - narrate "  <gray>- Erforderlichen Ruf zum Ansprechen des NPCs anpassen"
        - narrate "<yellow>/npcquest link <white>[NPCID]<yellow>"
        - narrate "  <gray>- Dem NPC diese Quest hinzufügen"
        - narrate <gray>-----------------------------
        - stop
    # NEU
    - if <context.args.get[1]||null> == neu:
        - define name <context.args.get[2]||null>
        - if <[name]> == null:
            - narrate "<red> Name fehlt: <yellow>/npcquest <red>[Name]"
            - stop
        - create player <[name]> <player.location> traits:lookclose save:npc
        - define npc <entry[npc].created_npc>
        - adjust <player> selected_npc:<[npc]>
        - define skin_blob <server.flag[npc_skins.quester]||null>
        - if skin_blob == null:
            - narrate "<red>Kein Skin namens quester gefunden:"
        - else:
            - adjust <[npc]> skin_blob:<server.flag[npc_skins.quester]>
        - assignment set script:quest_assi npc:<[npc]>
        - stop
    # CHECK SELECTION
    - if <player.selected_npc.script.name||null> != quest_assi:
        - narrate "<red>Kein quester NPC ausgewählt!"
        - stop
    # Texte
    - if <context.args.get[1]||null> == text:
        - define text <context.args.get[2]>
        - flag <player.selected_npc> quester.text:<[text]>
        - narrate "<green>quester Text geändert: <gray><[text]>"
    - if <context.args.get[1]||null> == antwort:
        - define text <context.args.get[2]>
        - flag <player.selected_npc> quester.antwort:<[text]>
        - narrate "<green>quester Text geändert: <gray><[text]>"
    # RUF
    - if <context.args.get[1]||null> == ruf:
        - if <context.args.get[2]||null> == nein:
            - flag <player.selected_npc> quester.ruf:!
        # - define ruf <map[gilde/|wert/<context.args.get[3]>]>
        - flag <player.selected_npc> quester.ruf.gilde:<context.args.get[2]>
        - flag <player.selected_npc> quester.ruf.wert:<context.args.get[3]>
        - narrate "<player.selected_npc> benötigt nun <context.args.get[3]> ruf bei <context.args.get[2]>"
    # LINK
    - if <context.args.get[1]||null> == link:
        - flag <npc> quests.quests:->:<context.args.get[2]>


quests_cmd:
    type: command
    name: quests
    usage: /quests
    debug: false
    description: quest verwaltung
    tab complete:
    # TODO: in scripts reload auch yaml files neu laden? und speichern ggf automatisch aus den commands?
    - define args1 <list[neu|laden|speichern|starten|info|täglich|vergessen|hilfe]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    - else if <context.args.get[1]||null> == vergessen:
        - determine <server.flag[quests].keys>
    - else if <list[starten|start].contains[<[args1]>]>:
        - determine <server.flag[quests].keys>

    script:
    # STAGE UPDATE
    - if <context.args.get[1]> == upstage:
        - define player <player>
        - define qid <context.args.get[2]>
        - run update_stage def:<[player]>|<[qid]>
        - stop
    # Questlog
    - if <context.args.get[1]> == logbuch:
        - define qid <context.args.get[2]||null>
        - define q <server.flag[quests.<[qid]>]>
        - define pq <player.flag[quests.aktiv.<[qid]>]>
        # - narrate "show quest: <[q].get[name]>"
        - define seite "<black><[q].get[name].bold><n>"
        - define track_btn "☞Track"
        - define cancel_btn "☞Abbruch"
        - define seite "<[seite]><dark_green><[track_btn].on_click[/quests updatestage <[qid]>]>  <dark_red><[cancel_btn].on_click[/quests vergessen <[qid]>]><p>"
        - define i 1
        - foreach <[q].get[stages]> as:stage:
            - if <[i]> == <[pq].get[stage]>:
                - define seite "<[seite]><black>⚜ <[stage].get[name].underline><n><dark_gray><[stage].get[desc]><p>"
            - else if <[i]> > <[pq].get[stage]>:
                - define seite "<[seite]><gray>⚜ <[stage].get[name]><p>"
            - else:
                - define seite "<[seite]><gold>✔ <[stage].get[name]><p>"
            - define i <[i].add_int[1]>
        - define buch <item[buch_item]>
        - adjust def:buch book_pages:<list[<[seite]>]>
        - adjust <player> show_book:<[buch]>
        - stop
    # CHECK
    - inject permissions_op
    - if !<list[neu|laden|speichern|starten|start|upstage|vergessen|info].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/quests neu <light_purple>QUEST-ID"
        - narrate "  <gray>- <blue>TODO:<gray> Interaktives erstellen einer Quest"
        - narrate "<yellow>/quests laden"
        - narrate "  <gray>- Lädt Quests aus Datei"
        - narrate "<yellow>/quests speichern"
        - narrate "  <gray>- Lädt Quests aus Datei"
        - narrate "<yellow>/quests info"
        - narrate "  <gray>- Listet alle Quest IDs auf"
        - narrate "<yellow>/quests starten <light_purple>QUEST-ID"
        - narrate "  <gray>- Eine Quest (neu)starten"
        - narrate "<yellow>/quests täglich <light_purple>QUEST-ID"
        - narrate "  <gray>- <blue>TODO: <gray>Quest auf die liste der Tagesquests setzen"
        - narrate "<yellow>/quests vergessen <light_purple>QUEST-ID (SPIELER)"
        - narrate "  <gray>- <blue> <gray>Quest für sich (/Spieler) zurücksetzen"
        - narrate <gray>-----------------------------
        - stop
    # START
    - if <list[starten|start].contains[<context.args.get[1]>]>:
        # TODO: switch to flags
        - define qname <context.args.get[2]>
        - run start_quest def:<[qname]>|<player>
    # LADEN
    - if <context.args.get[1]> == laden:
        # TODO: check single quest id in arg 3
        - yaml create id:quests
        - yaml load:quests/quests.yml id:quests
        - define quests <yaml[quests].read[quests]>
        - narrate <[quests].keys>
        - flag server quests:<[quests]>
        - narrate "<gray>Quests geladen"
    # SPEICHERN
    - if <context.args.get[1]> == speichern:
        # TODO: check single quest id in arg 3
        - yaml create id:quests
        - yaml id:quests set quests:<server.flag[quests]>
        - yaml id:quests savefile:quests/quests.yml
        - narrate "<gray>Quests gespeichert"
    # RESET
    - if <context.args.get[1]> == vergessen:
        - define qid <context.args.get[2]||null>
        - if !<server.has_flag[quests.<[qid]>]>:
            - narrate "<red>Quest nicht gefunden: <white><[qid]>"
        - define p <server.match_player[<context.args.get[3]||<player.name>>]>
        - flag <[p]> quests.aktiv.<[qid]>:!
        - flag <[p]> quests.fertig.<[qid]>:!
        - narrate "<gray> Quest <[qid]> vergessen für <[p].name>"


start_quest:
    type: task
    debug: false
    definitions: qid|player
    script:
    - playsound <[player]> sound:ENTITY_EXPERIENCE_ORB_PICKUP
    - wait 0.5
    - define quest <server.flag[quests].get[<[qid]>]||null>
    - title "title:<gold>Quest Angenommen<&co>" subtitle:<yellow><[quest].get[name]>
    - wait 1
    - define stagetxts <list[]>
    # - define idx 1
    - foreach <[quest].get[stages]> as:stage:
        - define stagetxts <[stagetxts].include[<gray><[stage].get[name]>]>
    - run update_player_sidebar def:<[player]>
    - sidebar remove players:<list[<[player]>]>
    - sidebar set title:<gold><[quest].get[name]> values:<[stagetxts]>
    - define q <map[id/<[qid]>|name/<[quest].get[name]>|stage/1]>
    - flag <[player]> quests.aktiv.<[qid]>:<[q]>


update_stage:
    type: task
    debug: false
    definitions: player|qid
    script:
    # - announce "DEBUG: <gray>Update Stage von <[player].name> in quest <[qid]>"
    - define q <server.flag[quests].get[<[qid]>]>
    # sidebar:
    - define stagetxts <list[]>
    - define idx 1
    - define s <[player].flag[quests.aktiv.<[qid]>.stage]||null>
    - foreach <[q].get[stages]> as:stage:
        - if <[s]> <= <[idx]>:
            - define stagetxts <[stagetxts].include[<gray><[stage].get[name]>]>
        - else:
            - define stagetxts <[stagetxts].include[<yellow><[stage].get[name]>]>
        - define idx <[idx].add_int[1]>
    - sidebar set "title:<gold><[q].get[name]>" "values:<[stagetxts]>"
    # quest fertig
    - if <[s]> > <[q].get[stages].size>:
        - playsound <[player]> sound:ENTITY_EXPERIENCE_ORB_PICKUP
        - sidebar remove
        - title "title:<gold>Quest Abgeschlossen<&co>" "subtitle:<yellow><[q].get[name]>"
        - if !<[q].get[redo]||null>==null:
            - define qcd <[q].get[redo].as_duration>
            - define qcd_text "<[qcd].formatted.replace[s].with[ Sekunden].replace[m].with[ Minuten].replace[d].with[ Tagen].replace[h].with[ Stunden]>"
            - narrate "<gray>Quest kann in <[qcd_text]> wiederholt werden."
            - flag <[player]> quests.fertig.<[qid]>:<[player].flag[quests.aktiv.<[qid]>]> duration:<[qcd]>
        - else:
            - flag <[player]> quests.fertig.<[qid]>:<[player].flag[quests.aktiv.<[qid]>]>
        - flag <[player]> quests.aktiv.<[qid]>:!
        - if <[q].get[rewards]||null> != null:
            - narrate "<dark_green>Belohnung:"
        - foreach <[q].get[rewards]> as:rew:
            - if <[rew].get[type]||null> == ruf:
                - define g <[rew].get[gilde]>
                - define r <[player].flag[ruf.<[g]>]||0>
                - define w <[rew].get[wert]||0>
                - flag <[player]> ruf.<[g]>:<[r].add_int[<[w]>]>
                - narrate "<dark_aqua><[w]><gray> Ruf bei <[g]>"
            - if <[rew].get[type]||null> == geld:
                - define g <[player].flag[geld]||0>
                - define w <[rew].get[wert]||0>
                - flag <[player]> geld:<[g].add_int[<[w]>]>
                - narrate "<gold><[w]><gray> Geld bekommen"


check_loot:
    type: task
    debug: false
    definitions: player
    script:
    # TODO: load yaml file earlier
    - yaml load:quests/quests.yml id:quests
    - define quests <yaml[quests].read[quests]>
    # - announce "Check loot: <[player]>"
    - foreach <[player].flag[quests.aktiv]> as:q:
        - define s <[q].get[stage]>
        - define qid <[q].get[id]>
        - define quest <[quests].get[<[qid]>]>
        - define stage <[quest].get[stages].get[<[s]>]>
        - if <[stage].get[task]||null> == loot:
            - define iname <[stage].get[item]||noname>
            - if <[player].inventory.contains.display[<[iname]>]>:
                - title "subtitle:<yellow>Erledigt: <[stage].get[name]>"
                - flag <[player]> quests.aktiv.<[qid]>.stage:<[player].flag[quests.aktiv.<[qid]>.stage].add_int[1]>
                - playsound <player> sound:ENTITY_EXPERIENCE_ORB_PICKUP
                - run update_stage def:<[player]>|<[qid]>


check_goto:
    type: task
    debug: false
    definitions: player|area
    script:
    # TODO: load yaml file earlier
    - yaml load:quests/quests.yml id:quests
    - define quests <yaml[quests].read[quests]>
    - foreach <[player].flag[quests.aktiv]> as:q:
        - define s <[q].get[stage]>
        - define qid <[q].get[id]>
        - define quest <[quests].get[<[qid]>]>
        - define stage <[quest].get[stages].get[<[s]>]>
        - if <[stage].get[task]||null> == goto:
            - if <[area]> == <cuboid[<[stage].get[area]>]>:
                - title "subtitle:<yellow>Erledigt: <[stage].get[name]>"
                - flag <[player]> quests.aktiv.<[qid]>.stage:<[player].flag[quests.aktiv.<[qid]>.stage].add_int[1]>
                - playsound <[player]> sound:ENTITY_EXPERIENCE_ORB_PICKUP
                - run update_stage def:<[player]>|<[qid]>


check_bring:
    type: task
    debug: false
    definitions: player|npc
    script:
    - ratelimit <player> 1s
    - if <[npc].type> != NPC:
        - stop
    - define quests <server.flag[quests]>
    - define consume_click false
    - foreach <[player].flag[quests.aktiv]> as:q:
        - define s <[q].get[stage]>
        - define qid <[q].get[id]>
        - define quest <[quests].get[<[qid]>]>
        - define stage <[quest].get[stages].get[<[s]>]>
        - if <[stage].get[task]||null> == bring:
            - if <npc.id> == <[stage].get[npc]>:
                # - narrate "bring task gefunden"
                - if !<[player].inventory.contains.display[<[stage].get[item]>]>:
                    - narrate "<red>Item fehlt: <[stage].get[item]>"
                - else:
                    - take bydisplay:<[stage].get[item]>
                    - title "subtitle:<yellow>Erledigt: <[stage].get[name]>"
                    - flag <[player]> quests.aktiv.<[qid]>.stage:<[player].flag[quests.aktiv.<[qid]>.stage].add_int[1]>
                    - playsound <player> sound:ENTITY_EXPERIENCE_ORB_PICKUP
                    - run update_stage def:<[player]>|<[qid]>
                    # - determine CANCELLED
        - else if <[stage].get[task]||null> == talk:
            - if <npc.id> == <[stage].get[npc]>:
                - title "subtitle:<yellow>Erledigt: <[stage].get[name]>"
                - flag <[player]> quests.aktiv.<[qid]>.stage:<[player].flag[quests.aktiv.<[qid]>.stage].add_int[1]>
                - playsound <player> sound:ENTITY_EXPERIENCE_ORB_PICKUP
                - run update_stage def:<[player]>|<[qid]>
                # - 





quest_listeners:
    type: world
    debug: false
    events:
        after player takes item:
        - if !<player.has_flag[quests.aktiv]>:
            - determine cancled
        - run check_loot def:<player>
        after player clicks in inventory:
        - if !<player.has_flag[quests.aktiv]>:
            - determine cancled
        - run check_loot def:<player>
        after player drags in inventory:
        - if !<player.has_flag[quests.aktiv]>:
            - determine cancled
        - run check_loot def:<player>
        # on player walks over notable:
        # - narrate <context.notable>
        # when a player walks over a notable location.
        # <context.notable> returns an ElementTag of the notable location's name.
        on player enters cuboid:
        - run check_goto def:<player>|<context.area>
        on player right clicks entity:
        - if !<player.has_flag[quests.aktiv]>:
            - determine cancled
        - run check_bring def:<player>|<context.entity>

