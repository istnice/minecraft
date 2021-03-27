general_events:
    type: world
    debug: false
    events:
        #| SPIELER STIRBT
        on player death in:world:
        # TODO: drop playerhead depending on cause?
        - narrate "Du bist tot"
        # Head drop at 10% chance
        - if <util.random.int[1].to[10]> == 1:
            - define head_name "<player.name>s Kopf"
            - define head player_head[skull_skin=<player.name>;display_name=<[head_name]>]
            - drop <[head]> <player.location>
        - determine passively NO_DROPS
        - determine passively NO_XP
        - determine passively KEEP_LEVEL
        - determine KEEP_INV

        #| SPIELER SPAWNT
        on player respawns:
        - narrate "Du lebst wieder"

        #| RELOAD SCRIPTS
        # on script reload:
        # TODO: check exclusions (move the lines where they belong)
        # - foreach <server.npcs> as:npc:
        #     - sneak <[npc]> fake

        # on time changes in world:
        # - announce "<gray>Es ist <context.time> Uhr!"
        on player right clicks trapped_chest:
            - narrate "<dark_gray>Verschlossen"
            - determine cancelled

        on structure grows naturally:
        # - announce "<gray>Pflanze wächst: <context.structure>"
        - determine cancelled



neustart_cmd:
    type: command
    name: neustart
    script:
    - inject permission_op
    - run auto_restarter_task


auto_restarter_world:
    type: world
    debug: false
    events:
        on system time 03:00:
        - run auto_restarter_task
        on player logs in server_flagged:restart_happening:
        - determine "KICKED:Server startet neu, bitte kurz warten."

auto_restarter_task:
    type: task
    debug: false
    script:
    - wait 1m
    - define marks <list[30m|20m|15m|10m|5m|4m|3m|2m|1m|30s|15s|10s|5s].parse[as_duration]>
    - foreach <[marks]> as:mark:
        - if <server.online_players.is_empty>:
            - foreach stop
        - define display_in "<[mark].formatted.replace[s].with[ Sekunden].replace[m].with[ Minuten].replace[1 Minuten].with[1 Minute]>"
        - announce "<&c>Server startet in <[display_in]> automatisch neu."
        - if <[mark].in_seconds> <= 60:
            - title "subtitle:<&c>Restart in <[display_in]>." fade_out:10s targets:<server.online_players>
            - flag server restart_happening duration:<[mark].add[10s]>
        - wait <[mark].sub[<[marks].get[<[loop_index].add[1]>]||0s>]||5s>
    - flag server restart_happening duration:5s
    - announce "<&c>Server Neustart!"
    - kick <server.online_players> "reason:Neustart! Bitte warte 1 Minute um dich wieder zu verbinden."
    - wait 1s
    - adjust server restart