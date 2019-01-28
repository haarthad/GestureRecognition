#https://github.com/ddunkijaco/shellScores
# This module belongs to ddunkijaco on github
#   It has been modified to work in Python 3

import datetime
from xml.etree import ElementTree
import json
import argparse
import requests

parser = argparse.ArgumentParser()
parser.add_argument('-l')
parser.add_argument('-t')
parser.add_argument('-d')
args = parser.parse_args()

games = []
home_score = []
heading = []
away_score = []

today = str(datetime.date.today())
yyyymmdd = today.replace('-', '')


def showBoxScore(date, league, team):
    header_space = ''
    header_print = ''
    away_print = ''
    home_print = ''
    url = 'http://scores.nbcsports.msnbc.com/ticker/data/gamesMSNBC.js.asp?sport=%s&period=%s'
    r = requests.get(url % (league, date))
    json_parsed = r.json()
    for game_str in json_parsed.get('games', []):
        game_tree = ElementTree.XML(game_str)
        away_tree = game_tree.find('visiting-team')
        home_tree = game_tree.find('home-team')
        gamestate_tree = game_tree.find('gamestate')
        home_nickname = home_tree.get('nickname')
        away_nickname = away_tree.get('nickname')
        home_alias = home_tree.get('alias')
        away_alias = away_tree.get('alias')
        team = team.lower()
        if away_nickname.lower() == team or home_nickname.lower() == team or home_alias.lower() == team or away_alias.lower() == team:
            if gamestate_tree.get('status') == "Pre-Game":
                print("Game starting at " + gamestate_tree.get('gametime') + " ET")
            elif gamestate_tree.get('status') == "In-Progress" or gamestate_tree.get(
                    'status') == "Delayed" or gamestate_tree.get('status').startswith("Final"):
                print('%s: %s %s %s' % (gamestate_tree.get('status'), gamestate_tree.get('display_status1'),
                                        gamestate_tree.get('display_status2'), gamestate_tree.get('reason')))

                # insert white space around score values
                home_score = insertWhitespace(home_tree.findall('score'), 'value')
                away_score = insertWhitespace(away_tree.findall('score'), 'value')
                heading = insertWhitespace(away_tree.findall('score'), 'heading')

                # equalize home/away nickname lengths
                while len(away_nickname) < len(home_nickname):
                    away_nickname = away_nickname + ' '
                while len(home_nickname) < len(away_nickname):
                    home_nickname = home_nickname + ' '
                while len(header_space) < len(away_nickname):
                    header_space = header_space + ' '

                # combine period/inning scores into string
                for x in range(len(heading)):
                    header_print += heading[x] + '|'
                    away_print += away_score[x] + '|'

                # if away team has batted but home team has not, create blank square
                if len(home_score) < len(away_score):
                    for x in range(len(home_score) - 3):
                        home_print += home_score[x] + '|'
                    home_print += '   |'
                    home_print += home_score[-3] + '|'
                    home_print += home_score[-2] + '|'
                    home_print += home_score[-1] + '|'
                else:
                    for x in range(len(heading)):
                        home_print += home_score[x] + '|'

                print(header_space + ' |' + header_print)
                print(away_nickname + ' |' + away_print)
                print(home_nickname + ' |' + home_print)
                break


def insertWhitespace(scores, attrib):
    spaced_scores = []
    for score in scores:
        if len(score.attrib.get(attrib)) == 1:
            spaced_scores.append(' %s ' % score.attrib.get(attrib))
        elif len(score.attrib.get(attrib)) == 2:
            spaced_scores.append(' %s' % score.attrib.get(attrib))
        else:
            spaced_scores.append('%s' % score.attrib.get(attrib))
    return spaced_scores


def showScores(leagues):
    for league in range(len(leagues)):
        response = requests.get('http://wu.apple.com/' + leagues[league].lower() + '/bottomline/xml/scores')
        events = ElementTree.fromstring(response.text)
        print('\n' + leagues[league].upper() + ':')
        for game in events.iter("GAME"):
            printScore(game)


def printScore(game):
    home_team = game.find('./HOME/TEAM').text
    home_score = game.find('./HOME/SCORE').text
    away_team = game.find('./AWAY/TEAM').text
    away_score = game.find('./AWAY/SCORE').text
    game_status = game.find('./STATUS').text
    print("%s: %s, %s: %s. %s" % (away_team, away_score, home_team, home_score, game_status))


if args.t:
    showBoxScore(args.d if args.d else yyyymmdd, args.l, args.t)
else:
    showScores(args.l.split(",") if args.l else ['NFL', 'MLB', 'NHL', 'NBA', 'NCF'])
