_ = require 'lodash'

BOARD_ID = process.env.HUBOT_HIRING_BOARD_ID

KEY_AND_TOKEN =
  key: process.env.HUBOT_TRELLO_KEY
  token: process.env.HUBOT_TRELLO_TOKEN

lists =
  new:
    id: '51acaaefbeac745c31005967'
    name: 'Nowe'
  gotOnHold:
    id: '550bf67451ab199493bdd811'
    name:'Dostał(a) maila z "on-hold"'
  gotSurvey:
    id: '51ade0b03e79ff244a001071'
    name: 'Dostał(a) ankietę'
  preScreening:
    id: '51f63c8487eaf62c15003a51'
    name: 'Pre-screening call'
  taskInProgress:
    id: '51f63c74faa4a1497b00446b'
    name: 'Robi zadanie'
  codeReview:
    id: '51f63cb51e9bf75b7b00386e'
    name: 'Code review'
  technicalCall:
    id: '5478db810b6b5ab72c591a59'
    name: 'Rozmowa techniczna'
  lunch:
    id: '5478db8c51399a1f75cc45b2'
    name: 'Lunch'
  withDoubts:
    id: '51acaaefbeac745c31005969'
    name: 'Z wątpliwościami'
  rejected:
    id: '51acaaefbeac745c31005968'
    name: 'Odrzucone'

findCard = (query, robot, successCallback, errorCallback) ->
  searchParams =
    modelTypes: 'cards'
    idBoards: BOARD_ID
    query: query

  extractCard = (json) ->
    switch json.cards.length
      when 0 then errorCallback "nie znalazłem kartki dla \"#{query}\""
      when 1 then successCallback fillListName(json.cards[0])
      else errorCallback "znalazłem więcej niż jedną kartkę dla \"#{query}\""

  get('https://api.trello.com/1/search', searchParams, robot, extractCard, errorCallback)

findAllCards = (robot, successCallback, errorCallback) ->
  fillListNames = (cards) ->
    successCallback(_.map(cards, fillListName))

  get("https://api.trello.com/1/boards/#{BOARD_ID}/cards", {}, robot, fillListNames, errorCallback)

fillListName = (card) ->
  card.listName = findListById(card.idList)?.name
  card

findListById = (id) ->
  _.find(lists, id: id)

extractEmailAddress = (card) ->
  matches = card.name.match(/#(.*)#/)
  matches[1] if matches?

moveToGotSurvey = (card, robot, successCallback, errorCallback) ->
  moveCardToList(card, lists.gotSurvey, robot, successCallback, errorCallback)

moveToTaskInProgress = (card, robot, successCallback, errorCallback) ->
  moveCardToList(card, lists.taskInProgress, robot, successCallback, errorCallback)

moveCardToList = (card, targetList, robot, successCallback, errorCallback) ->
  put("https://api.trello.com/1/cards/#{card.id}/idList", {value: targetList.id}, robot, successCallback, errorCallback)

isNew = (card) -> isCardInList(card, lists.new)

isPreScreening = (card) -> isCardInList(card, lists.preScreening)

isTaskInProgress = (card) -> isCardInList(card, lists.taskInProgress)

isCardInList  = (card, list) -> card.idList is list.id

query = (url, queryParams, robot) -> robot.http(url).query(_.assign(KEY_AND_TOKEN, queryParams))

request = (f, successCallback, errorCallback) ->
  f (err, res, body) ->
    if err
      errorCallback err
    else
      successCallback JSON.parse(body)

get = (url, queryParams, robot, successCallback, errorCallback) ->
  request(query(url, queryParams, robot).get(), successCallback, errorCallback)

put = (url, queryParams, robot, successCallback, errorCallback) ->
  request(query(url, queryParams, robot).put(), successCallback, errorCallback)

module.exports =
  findCard: findCard
  findAllCards: findAllCards
  extractEmailAddress: extractEmailAddress
  moveToGotSurvey: moveToGotSurvey
  moveToTaskInProgress: moveToTaskInProgress
  isNew: isNew
  isPreScreening: isPreScreening
  isTaskInProgress: isTaskInProgress
