teleporter_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - sneak <npc> start fake
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
        on click:
        # - playeffect effect:VILLAGER_HAPPY location:<npc.location>
        # check requirements
        - if <npc.has_flag[teleporter.ruf]>:
            # - narrate "<gray> Req found"
            - define nruf <npc.flag[teleporter.ruf.wert]||null>
            - define pruf <player.flag[ruf.<npc.flag[teleporter.ruf.gilde]>]||0>
            - if <[nruf]> > <[pruf]> || <[nruf]>==null:
                - narrate "<red>Nicht genug Ruf um mit diesem NPC zu reden! <[pruf]>/<[nruf]>"
                - determine cancelled
        - define partner <npc.flag[teleporter.link]>
        - flag <player> teleporter.npc:<npc> duration:120s
        - define ziel <[partner].anchor[ziel]||<[partner].location>>
        - flag <player> teleporter.ziel:<[ziel]> duration:60s
        # - narrate "ziel gesetzt: <player.flag[teleporter.ziel]>"
        - define book <item[buch_item]>
        - define antwort "<blue>❉ <npc.flag[teleporter.antwort].on_click[/teleporterport]>"
        - define seite <npc.flag[teleporter.text]><p><[antwort]>
        - adjust def:book book_pages:<list[<[seite]>|]>
        - adjust <player> show_book:<[book]>
        - determine cancelled


teleporterport:
    type: command
    usage: /teleporterport
    name: teleporterport
    description: Ausgef. von NPC buch klick
    debug: false
    script:
    - inject permission_op
    - define npc <player.flag[teleporter.npc]||null>
    - define ziel <player.flag[teleporter.ziel]||null>
    - if <[ziel]> == null:
        - narrate "<red>Ziel ungültig. <gray>Versuche es erneut."
        - stop
    - if <[npc]> == null:
        - narrate "<red>NPC ungültig. <gray>Versuche es erneut."
        - stop
    # blind player
    - define effects <player.list_effects>
    # TODO: perfekt schwarz haengt von tages zeit ab (individuelle spielerzeit setzen?)
    # - adjust <[player]> potion_effects:<player.list_effects.include[EFFECT,AMPLIFY,DURATION,IS_AMBIENT,HAS_PARTICLES,HAS_ICON]>
    # - adjust <[player]> potion_effects:<player.list_effects.include[NIGHT_VISION,255,120,true,true,false]>
    # - adjust <[player]> potion_effects:<player.list_effects.include[BLINDNESS,255,120,true,true,false]>
    - adjust <player> potion_effects:<list[BLINDNESS,255,40,false,true,false|NIGHT_VISION,255,40,false,true,false]>
    # - adjust <[player]> potion_effects:<list[NIGHT_VISION,255,120,true,true,false]>
    - wait 1
    - teleport <player> <[ziel]>


teleporter_cmd:
    type: command
    name: npcteleporter
    usage: /npcteleporter [neu/ruf/seite/editor]
    description: assigns teleporter and sets flags
    debug: false
    tab complete:
    - define args1 <list[neu|info|ruf|preis|text|antwort|link|hilfe]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    - else if <context.args.get[1]> == neu:
        - determine <list[NAME]>
    - else if <context.args.get[1]> == link:
        - define tnpcs <server.npcs_assigned[teleporter_assi]>
        - define tids <list[]>
        - foreach tnpcs as:n:
            - define tids <[tids].include[<[n].id>]>
        - determine <[tids]>
    - else if <context.args.get[1]> == text:
        - define txt "&quoLANGER TEXT&quo"
        - determine <list[<[txt].unescaped>]>
    - else if <context.args.get[1]> == antwort:
        - define ant "&quoANTWORT TEXT&quo"
        - determine <list[<[ant].unescaped>]>

    script:
    - inject permission_op
    # check commands
    - if !<list[neu|info|ruf|preis|text|antwort|link].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/npcteleporter neu <white>[NAME]"
        - narrate "  <gray>- Erstellt NPC der Spieler teleportiert (name ohne leerzeichen)"
        - narrate "<yellow>/npcteleporter info"
        - narrate "  <gray>- Zeigt Ziel, Text, Preis, Ruf des NPC"
        - narrate "<yellow>/npcteleporter ruf <white>[GILDE] [MENGE]"
        - narrate "  <gray>- Erforderlichen Ruf zum Ansprechen des NPCs anpassen"
        - narrate "<yellow>/npcteleporter preis <white>[GELD]"
        - narrate "  <gray>- Kosten einer Teleportation"
        - narrate "<yellow>/npcteleporter text &quo<white>[TEXT]<yellow>&quo"
        - narrate "  <gray>- Text des Dialogbuchs ändern."
        - narrate "<yellow>/npcteleporter antwort &quo<white>[TEXT]<yellow>&quo"
        - narrate "  <gray>- Antworttext des Dialogbuchs ändern."
        - narrate "<yellow>/npcteleporter link <white>[NPCID]<yellow>"
        - narrate "  <gray>- Zwei Teleporter manuell verbinden."
        - narrate <gray>-----------------------------
        - stop
    # NEU
    - if <context.args.get[1]||null> == neu:
        - define name <context.args.get[2]||null>
        - if <[name]> == null:
            - narrate "<red> Name fehlt: <yellow>/npcteleporter <red>[Name]"
            - stop
        - create player <[name]> <player.location> traits:lookclose save:npc
        - define npc <entry[npc].created_npc>
        - adjust <player> selected_npc:<[npc]>
        - define skin_blob <server.flag[npc_skins.teleporter]||null>
        - if skin_blob == null:
            - narrate "<red>Kein Skin namens teleporter gefunden:"
        - else:
            - adjust <[npc]> skin_blob:<server.flag[npc_skins.teleporter]>
        - assignment set script:teleporter_assi npc:<[npc]>
        # clone?
        - define pid <context.args.get[3]||null>
        - if <[pid]> == null:
            - define defans "Antwort! (ändern mit <yellow>/npcteleporter antwort<black>)"
            - define deftxt "Text! Dieser Text wird mit dem Befehl <yellow>/npcteleporter text<black> geändert. Dieser NPC muss ausgewählt sein und er Text in Anführungszeichen."
            - flag <[npc]> teleporter.antwort:<[defans]>
            - flag <[npc]> teleporter.text:<[deftxt]>
            # - flag <[npc]> teleporter.text:<[partner].flag[teleporter.text]>
            - narrate "<gray>Kein Links: Neuen NPC als Teleporter erstellen"
            - narrate "<gray>Teleporter erstellt. Um sein Gegenstück zu spawnen und zu verbinden benutze: <yellow>/npcteleporter neu <[npc].name> <[npc].id>"
        - else:
            - narrate "<gray>Klon von NPC als Teleporter erstellen und verbinden."
            - define partner <npc[<[pid]>]>
            - flag <[npc]> teleporter:<[partner].flag[teleporter]>
            - flag <[npc]> teleporter.link:<[partner]>
            - flag <[partner]> teleporter.link:<[npc]>
    # CHECK SELECTION
    - if <player.selected_npc.script.name||null> != teleporter_assi:
        - narrate "<red>Kein teleporter NPC ausgewählt!"
        - stop
    # Texte
    - if <context.args.get[1]||null> == text:
        - define text <context.args.get[2]>
        - flag <player.selected_npc> teleporter.text:<[text]>
        - narrate "<green>Teleporter Text geändert: <gray><[text]>"
    - if <context.args.get[1]||null> == antwort:
        - define text <context.args.get[2]>
        - flag <player.selected_npc> teleporter.antwort:<[text]>
        - narrate "<green>Teleporter Text geändert: <gray><[text]>"
    # RUF
    - if <context.args.get[1]||null> == ruf:
        - if <context.args.get[2]||null> == nein:
            - flag <player.selected_npc> teleporter.ruf:!
        # - define ruf <map[gilde/|wert/<context.args.get[3]>]>
        - flag <player.selected_npc> teleporter.ruf.gilde:<context.args.get[2]>
        - flag <player.selected_npc> teleporter.ruf.wert:<context.args.get[3]>
        - narrate "<player.selected_npc> benötigt nun <context.args.get[3]> ruf bei <context.args.get[2]>"

