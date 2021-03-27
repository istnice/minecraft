# +-------------------
# |
# | Alles rund ums Kriegsschiff
# |
# | Kanonenfeuer, 
# |
# +----------------------
#
# @author Sarbot
# @date 2021/01/26
# @script-version 1.1.8
#
# Installation:
# Just put the script in your scripts folder and reload.
#
#
# Uses individual permissions
#
# ---------------------------- END HEADER ----------------------------


kanonen_feuer_command:
  type: command
  debug: false
  name: kanonenfeuer
  usage: /kanonenfeuer
  description: Feuert alle kanonen vom Kriegsschiff
  permission: denizen.kriegsschiff
  script:
  - inject permission_op
  - define kanone n@23
  - define ziel n@25
  - playsound <[kanone].location> sound:ENTITY_DRAGON_FIREBALL_EXPLODE pitch:1
  - wait 0.02
  - playsound <[kanone].location> sound:ENTITY_DRAGON_FIREBALL_EXPLODE pitch:1
  - shoot fireball origin:<[kanone].location.add[-4.0,0,-6]> destination:<[ziel].location.add[0,0,-6]> speed:5
  - shoot fireball origin:<[kanone].location.add[-4.0,0,-32]> destination:<[ziel].location.add[0,0,-30]> speed:5
  - shoot fireball origin:<[kanone].location.add[-4.0,0,-12]> destination:<[ziel].location.add[0,0,-12]> speed:5
  - wait 0.05
  - playsound <[kanone].location> sound:ENTITY_DRAGON_FIREBALL_EXPLODE pitch:1
  - shoot fireball origin:<[kanone].location.add[-4.0,0,-32]> destination:<[ziel].location.add[0,0,-42]> speed:5
  - shoot fireball origin:<[kanone].location.add[-4.0,0,0]> destination:<[ziel].location.add[0,0,0]> speed:5
  - shoot fireball origin:<[kanone].location.add[-4.0,0,-24]> destination:<[ziel].location.add[0,0,-24]> speed:5
  - wait 0.02
  - playsound <[kanone].location> sound:ENTITY_DRAGON_FIREBALL_EXPLODE pitch:1
  - shoot fireball origin:<[kanone].location.add[-4.0,0,-18]> destination:<[ziel].location.add[0,0,-18]> speed:5
  - wait 0.01
  - shoot fireball origin:<[kanone].location.add[-4.0,0,-32]> destination:<[ziel].location.add[0,0,-30]> speed:5
  - shoot fireball origin:<[kanone].location.add[-4.0,0,6]> destination:<[ziel].location.add[0,0,-6]> speed:5
  - wait 0.1
  - playsound <[kanone].location> sound:ENTITY_DRAGON_FIREBALL_EXPLODE pitch:1