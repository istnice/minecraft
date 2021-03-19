fightdog_assi:
    type: assignment
    actions:
        on assignment:
        # target player when close (in region below y) priority
        - trigger name:click state:true
        - trigger name:death state:true
        - sneak <npc> start fake
        - trait state:true sentinel
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
        on click:
        - if !<player.has_flag[geld]>:
            - flag <player> geld:0
        - define fight <npc.flag[richter]>
        - if <[fight].flag[state]||null> == prepare:
            - if <player.flag[geld]||0> < 20:
                - narrate "<red>Nicht genug Geld zum Wetten!"
                - stop
            - narrate "<gray>Du hast <red>10g<gray> auf <npc.name> gesetzt."
            - flag <player> dogbet:<npc>
            - flag <player> geld:<player.flag[geld].sub_int[10]>
        - else if <[fight].flag[state]> == fighting:
            - narrate "<npc.name> hat <npc.health_data> Leben."
        on death:
        - define npc <npc.flag[richter]>
        - flag <[npc]> state:winner
        - flag <[npc]> looser:<npc>

dogfight_assi:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
        on click:
        - cooldown 2
        - define state <npc.flag[state]||null>

        # erster spieler der klickt
        - if <[state]> == null:
            # main event script: Prepare
            - flag <npc> state:prepare
            - define a1 <npc.flag[hunde].get[1]>
            - define a2 <npc.flag[hunde].get[2]>
            # setup a1
            - execute as_server "sentinel respawntime 30 --id <[a1].id>" silent
            - execute as_server "sentinel respawn --id <[a1].id>" silent
            - execute as _server "sentinel health <util.random.int[10].to[15]> --id <[a1]>"
            - execute as _server "sentinel damage <util.random.int[2].to[4]> --id <[a1]>"
            - teleport <[a1]> <npc.anchor[start1]>
            - execute as_server "sentinel spawnpoint --id <[a1].id>" silent
            # setup a2
            - execute as_server "sentinel respawntime 30 --id <[a2].id>" silent
            - execute as_server "sentinel respawn --id <[a2].id>" silent
            - execute as _server "sentinel health <util.random.int[10].to[15]> --id <[a2]>"
            - execute as _server "sentinel damage <util.random.int[2].to[4]> --id <[a2]>"
            - teleport <[a2]> <npc.anchor[start2]>
            - execute as_server "sentinel spawnpoint --id <[a2].id>" silent
            # accept bets
            - chat "Gleich beginnt der Kampf."
            - chat "Wetten können abgegeben werden!"
            - narrate "<gray>Rechtsklick auf deinen Favoriten, um 10bg zu setzen."
            - wait 10
            # main event fight
            - flag <npc> state:fighting
            - chat "Es geht los!" no_target
            - switch <npc.anchor[gate1]> open:off
            - switch <npc.anchor[gate2]> open:off
            - switch <npc.anchor[gate3]> open:off
            - switch <npc.anchor[gate4]> open:off
            - switch <npc.anchor[gate1].add[0,1,0]> open:off
            - switch <npc.anchor[gate2].add[0,1,0]> open:off
            - switch <npc.anchor[gate3].add[0,1,0]> open:off
            - switch <npc.anchor[gate4].add[0,1,0]> open:off
            - wait 1.5
            - switch <npc.anchor[gate1]> open:on
            - switch <npc.anchor[gate2]> open:on
            - switch <npc.anchor[gate3]> open:on
            - switch <npc.anchor[gate4]> open:on
            - switch <npc.anchor[gate1].add[0,1,0]> open:on
            - switch <npc.anchor[gate2].add[0,1,0]> open:on
            - switch <npc.anchor[gate3].add[0,1,0]> open:on
            - switch <npc.anchor[gate4].add[0,1,0]> open:on
            # fight over
            - waituntil <npc.flag[state]> == winner rate:3
            - wait 1
            - if <[a1]> == <npc.flag[looser]>:
                - define winner <[a2]>
                - define looser <[a1]>
            - else:
                - define winner <[a1]>
                - define looser <[a2]>
            - chat "Der Sieger ist: <[winner].name> " talkers:<npc> no_target
            # - chat "gekämpft haben: <npc.flag[hunde].get[1]> gegen <npc.flag[hunde].get[2]>" talkers:<npc> no_target
            - wait 0.5
            - narrate <player.flag[dogbet]>
            - foreach <server.online_players> as:p:
                # - narrate <[p]>
                # - narrate <[p].flag[dogbet]>
                # - debug LOG <[p]>
                # - debug LOG <[p].flag[dogbet]>
                - if <[p].flag[dogbet]> == <[winner]>:
                    - flag <[p]> geld:<[p].flag[geld].add_int[20]>
                    - narrate "<gray>Du hast <green>20g<gray> gewonnen!" targets:<[p]>
                    - flag <player> dogbet:!
                - else if <[p].flag[dogbet]> == <[looser]>:
                    - narrate "<gray>Du hast deine Wette verloren." targets:<[p]>
                    - flag <player> dogbet:!
                # - else:
                #     - narrate "<gray><[p]> hat nichts mit der Wette zu tun."
            - wait 5
            - spawn <npc.flag[hunde].get[1]>
            - spawn <npc.flag[hunde].get[2]>
            - teleport <npc.flag[hunde].get[1]> <npc.anchor[start1]>
            - teleport <npc.flag[hunde].get[2]> <npc.anchor[start2]>
            - wait 1
            - flag <npc> state:!
            # reset

        # klicks in vorbereitung
        - else if <[state]> == prepare:
            - chat "Der Kampf beginnt in Kürze, möchtest du noch wetten?"
            - narrate "<gray>Rechtsklick auf deinen Favoriten, um 10bg zu setzen."

        # klicks während des kampfes
        - else if <[state]> == fighting:
            - chat "Ich bin beschäftigt, der Kampf läuft."


dogfight_cmd:
    type: command
    name: dogfight
    usage: /dogfight
    dscription: "moderiert den dogfight"
    script:
    - if !<list[create|info|hund|anmelden|abmelden|reset].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/dogfight info <white>[NAME]"
        - narrate "  <gray>- Zeigt Infos zu den Kämpfen des ausgewählten NPC."
        - narrate "<yellow>/dogfight create <white>[NAME]"
        - narrate "  <gray>- Erstellt einen NPC der Hundekämpfe veranstaltet"
        - narrate "<yellow>/dogfight hund [NAME] (COLOR)"
        - narrate "  <gray>- Erstellt einen Hund, der kämpfen kann. (Wird automatisch angemeldet, wenn NPC ausgewählt ist.)"
        - narrate "<yellow>/dogfight anmelden"
        - narrate "  <gray>- Kampfhund muss selected sein und NPC anvisieren."
        - narrate "<yellow>/dogfight abmelden"
        - narrate "  <gray>- Meldet ausgewählten hund von allen Kämpfen ab"
        - narrate <gray>-----------------------------
        - stop

    # Info des NPC vorlesen
    - if <context.args.get[1]> == info:
        - define fight <player.selected_npc||null>
        - if <[fight].script.name||null> != dogfight_assi:
            - narrate "<red>Kein dogfight NPC ausgeählt."
        - narrate "<gray>Name: <blue><[fight].name>"
        - narrate "<gray>State: <blue><[fight].flag[state]||bereit>"
        - narrate "<gray>Hunde: "
        - foreach <[fight].flag[hunde]||<list[]>> as:hund:
            - narrate "  <blue>- <[hund].name>"
        - narrate "<gray>Offene Wette: <blue><player.flag[hundewette].name||keine>"

    - else if <context.args.get[1]> == reset:
        - define fight <player.selected_npc||null>
        - if <[fight].script.name||null> != dogfight_assi:
            - narrate "<red>Kein dogfight NPC ausgeählt."
        - flag <[fight]> state:null
    # NPC/Fight erstellen
    - else if <context.args.get[1]> == create:
        - create player <context.args.get[2]||Hundekampfrichter> <player.location> save:npc
        - adjust <player> selected_npc:<entry[npc].created_npc>
        - if <server.has_flag[npc_skins.hundekampf]>:
            - adjust <player.selected_npc> skin_blob:<server.flag[npc_skins.hundekampf]>
        - else:
            - narrate "<red>Kein Skin namens hundekampf gefunden:"
        - assignment set script:dogfight_assi npc:<player.selected_npc>
        - narrate "<gray>Hundekampf erstellt. Mindestens 2 Hunde müssen erstellt werden. Hunde ohne <yellow>/npc anchor --save tor<gray>  werden teleportiert/gespawnt wenn der Kampf beginnt."
        - stop

    # Hund erstellen
    - else if <context.args.get[1]> == hund:
        - if <context.args.get[2]||null> == null:
            - narrate "<red>Fehler <white>(Name fehlt): <yellow>/dogfight hund <red>[NAME]<yellow> (COLOR)"
            - stop
        - create wolf <context.args.get[2]> <player.location> traits:sentinel save:hund
        - define hund <entry[hund].created_npc>
        - if <player.target.script.name||null> == dogfight_assi:
            - define richter <player.target>
        - else if <player.selected_npc.script.name||null> == dogfight_assi:
            - define richter <player.selected_npc>
        - if <[richter]||null> != null:
            - flag <[richter]> hunde:->:<[hund]>
            - narrate "<green>Kampfrichter erkannt! <gray>Hund wird automatisch angemeldet."
        - else:
            - narrate "<red> Kein Kampfrichter erkannt, hund muss angemeldet werden."
        - adjust <player> selected_npc:<[hund]>
        - assignment set script:fightdog_assi npc:<[hund]>
        # - execute as_server "sentinel stuffhere --id <npc.id>" silent
        # spawnpoint
        # - execute as_server "sentinel spawnlocation"
        - execute as_server "sentinel respawntime 20 --id <[hund].id>" silent
        - execute as_server "sentinel health 50 --id <[hund].id>" silent
        - execute as_server "sentinel damage 6 --id <[hund].id>" silent
        - execute as_server "sentinel squad dogfight --id <[hund].id>" silent
        - execute as_server "sentinel addtarget squad:dogfight --id <[hund].id>" silent
        # squad dogfight
        # addtarget squad:dogfight

    # Hund anmelden
    - else if <context.args.get[1]> == anmelden:
        - define fight <npc[<player.target>]>
        # - narrate <[fight].script>
        - if <[fight].script.name||null> != dogfight_assi:
            - narrate "<red>Hundekampfrichter anvisieren, zum anmelden."
            - stop
        - define hund <npc[<player.selected_npc>]>
        - if <[hund].script.name||null> != fightdog_assi:
            - narrate "<red>Kein Kampfhund ausgewählt: <yellow>/npc sel"
            - stop
        - flag <[fight]> hunde:->:<[hund]>
        - flag <[hund]> richter:<[fight]>
        - narrate "<green>Hund angemeldet"

