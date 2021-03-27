# +--------------------
# |
# | NPC   Chessgame
# |
# | Ein Ingame schachspiel mit 16 NPCs als figuren
# |
# +----------------------
#
# @author sarbot
# @date 2021/02/01
# @script-version 1.1
#
# Installation:
# Just put the script in your scripts folder and reload.
#
# Usage:
# Select an NPC and use command "/npcchesspiece [white/black] [piece]"
#
# You can do:
# /npcschachfigur [farbe] [rolle]  - assign a chess piece to an npc
# /schach ready weiss
# /schach ready schwarz
# /schach reset
# /schach
#
# Farben sind: weiss, schwarz
# Rollen sind: koenig, dame, turm, laeufer, bauer, springer
#
# Players can right-click the NPC at any time to see a message.
#
# ---------------------------- END HEADER ----------------------------


chess_command:
    type: command
    name: schach
    debug: false
    usage: /schach [action]
    description: Definiert Ankerpunkt des Schachbretts (ecke neben dem feld "0,0")
    script:
    - inject permission_op

    # ANKER
    - if <context.args.get[1]> == anker:
        - flag server chessx:<context.args.get[1]>
        - flag server chessy:<context.args.get[2]>
        - narrate "server flags set: schach init position: <server.flag[chessx]> <server.flag[chessz]>"
        - stop

    # RESET
    - if <context.args.get[1]> == reset:
        - narrate "Schachbrett aufräumen."
        - foreach <server.players> as:player:
            - flag <[player]> aktive_figur:!
        - foreach <server.flag[chessnpcs]> as:figur:
            - glow <[figur]> false
            - if !<[figur].is_spawned>:
                - spawn <[figur]>
            - flag <[figur]> x:<[figur].flag[posx]>
            - flag <[figur]> z:<[figur].flag[posz]>
            - if <[figur].flag[farbe]> == weiss:
                - define yaw 270
            - else:
                - define yaw 90
            - if <[figur].flag[rolle]> == bauer:
                - define z 102.5
            - else:
                - define z 103
            - define anchor <location[-2236.5,<[z]>,1961.5,0,<[yaw]>,world]>
            # yaw 180 white
            # yaw 0 black
            - teleport <[figur]> <[anchor].add[<[figur].flag[posx]>,0.0,<[figur].flag[posz]>]>

    # LIST
    - if <context.args.get[1]> == list:
        - narrate <server.flag[chessnpcs]>

    # CLEARLIST
    - if <context.args.get[1]> == clearlist:
        - flag server chessnpcs:!
        - narrate "alle figuren unregistered"

    # FIGUR ZUWEISEN
    - if <context.args.get[1]> == figur:
        - if !<list[weiss|schwarz].contains[<context.args.get[2]||null>]>:
            - narrate "Argument muss weiss oder schwarz sein. zB: <yellow>/schach figur weiss laeufer 1 3"
            - stop
        - if !<list[koenig|dame|turm|laeufer|bauer|springer].contains[<context.args.get[3]||null>]>:
            - narrate "Argument muss koenig, dame, turm, laeufer, bauer oder springer sein. zB: <yellow>/schach figur weiss laeufer 1 3"
            - stop
        - if <player.selected_npc||null> == null:
            - narrate "Kein NPC ausgewählt: <yellow>/npc sel"
            - stop
        - flag <player.selected_npc> farbe:<context.args.get[2]>
        - flag <player.selected_npc> rolle:<context.args.get[3]>
        - flag <player.selected_npc> posx:<context.args.get[4]>
        - flag <player.selected_npc> posz:<context.args.get[5]>
        - if <server.flag[chessnpcs].contains[<player.selected_npc>]>:
            - narrate "NPC <player.selected_npc.id> ist schon Teil des spiels"
        - else:
            - flag server chessnpcs:->:<player.selected_npc>
            - narrate "NPC <player.selected_npc.id> gehört jetzt zum Spiel"
        - assignment set script:chess_piece_assignment npc:<player.selected_npc>

    # REGELN
    - if <context.args.get[1]> == regeln:
        - if <context.args.get[2]> == ja:
            - flag server chessrules:true
        - else if <context.args.get[2]> == nein:
            - flag server chessrules:false
        - else:
            - if <server.flag[chessrules]>:
                - narrate "<gray>Schachregeln aktiv"
            - else:
                - narrate "<gray>Schachregeln inaktiv"
            - narrate "<gray>Ein/Ausschalten der Regeln mit <red>/schach regeln ja <gray> bzw. <red>/schach regeln nein"


chess_piece_assignment:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
        on click:
        - if !<player.has_flag[aktive_figur]>:
            - glow <npc>
            - flag <player> aktive_figur:<npc>
        - else:
            - narrate "Es ist bereits eine figur ausgewählt!"
        # disable all other?


chess_events:
    type: world
    debug: false
    events:
        on player left clicks block:
        - if !<player.has_flag[aktive_figur]>:
            - stop

        # relative move, dx/dz
        - define fig <player.flag[aktive_figur]>
        # TODO use an anchor
        # - define x1 <context.location.x.sub[-2319]>
        - define x1 <context.location.x.sub[-2237]>
        # - define z1 <context.location.z.sub[258]>
        - define z1 <context.location.z.sub[1961]>
        - define x0 <npc[<[fig]>].flag[x]>
        - define z0 <npc[<[fig]>].flag[z]>
        - define dx <[x1].sub[<[x0]>]>
        - define dz <[z1].sub[<[z0]>]>

        # target
        - foreach <server.flag[chessnpcs]> as:figur:
            - if <[figur].flag[x]> == <[x1]> && <[figur].flag[z]> == <[z1]>:
                - narrate "<npc[<[fig]>].name> schlägt <[figur].name>"
                - despawn <[figur]>

        # todo validate move
        - define fail_msg "<red>Dieser Zug ist nicht erlaubt."
        - define dx <[x].sub[<player.flag[aktive_figur].flag[x]>]>
        # - narrate "move: <[dx]>"
        # - narrate "move to <[x]>, <[z]>"
        # todo kick out enemy npc (check collision with own color too)
        - teleport <player.flag[aktive_figur]> <context.location.add[0.5,0,0.5]>
        - flag <npc[<player.flag[aktive_figur]>]> x:<[x1]>
        - flag <npc[<player.flag[aktive_figur]>]> z:<[z1]>
        - glow <player.flag[aktive_figur]> false
        - flag <player> aktive_figur:!
        # consume click
        - determine cancelled