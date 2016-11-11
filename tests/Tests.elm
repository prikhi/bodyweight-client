module Tests exposing (..)

import Array
import Expect
import Models.Exercises exposing (initialExercise, exerciseType)
import String
import Test exposing (Test, test, describe)
import Utils exposing (findById, removeByIndex, updateByIndex, indexIsSaved, swapIndexes)


all : Test
all =
    describe "Application"
        [ exerciseModelTests
        , utilsTests
        ]


exerciseModelTests : Test
exerciseModelTests =
    describe "Models.Exercises"
        [ exerciseTypeTests
        ]


exerciseTypeTests : Test
exerciseTypeTests =
    describe "exerciseType"
        [ test "hold exercises are correctly represented" <|
            \() ->
                Expect.equal "Hold" <|
                    exerciseType { initialExercise | isHold = True }
        , test "rep exercises are correctly represented" <|
            \() ->
                Expect.equal "Reps" <|
                    exerciseType { initialExercise | isHold = False }
        ]


utilsTests : Test
utilsTests =
    describe "Utils"
        [ findByIdTests
        , indexIsSavedTests
        , removeByIndexTests
        , updateByIndexTests
        , swapIndexesTests
        ]


findByIdTests : Test
findByIdTests =
    describe "findById"
        [ test "empty list returns nothing" <|
            \() ->
                Expect.equal Nothing (findById 42 [])
        , test "singleton with match returns item" <|
            \() ->
                Expect.equal (Just { id = 42 }) <|
                    findById 42 [ { id = 42 } ]
        , test "singleton without match returns nothing" <|
            \() ->
                Expect.equal Nothing <|
                    findById 42 [ { id = 24 } ]
        , test "no matches returns nothing" <|
            \() ->
                Expect.equal Nothing <|
                    findById 42 [ { id = 41 }, { id = 43 } ]
        , test "multiple matches returns first item" <|
            \() ->
                Expect.equal (Just { id = 42, x = "first" }) <|
                    findById 42
                        [ { id = 42, x = "first" }
                        , { id = 42, x = "second" }
                        ]
        ]


indexIsSavedTests : Test
indexIsSavedTests =
    describe "indexIsSaved"
        [ test "empty array returns false" <|
            \() ->
                Expect.equal False (indexIsSaved 0 Array.empty)
        , test "index greater than length is false" <|
            \() ->
                Expect.equal False <|
                    indexIsSaved 1 (Array.fromList [ { id = 1 } ])
        , test "id of 0 returns false" <|
            \() ->
                Expect.equal False <|
                    indexIsSaved 0 (Array.fromList [ { id = 0 } ])
        , test "non-zero id returns true" <|
            \() ->
                Expect.equal True <|
                    indexIsSaved 0 (Array.fromList [ { id = 42 } ])
        ]


removeByIndexTests : Test
removeByIndexTests =
    describe "removeByIndex"
        [ test "empty array returns empty array" <|
            \() ->
                Expect.equal Array.empty (removeByIndex 1 Array.empty)
        , test "index greater than length has no effect" <|
            \() ->
                Expect.equal (Array.fromList [ 1, 2, 3 ]) <|
                    removeByIndex 9001 (Array.fromList [ 1, 2, 3 ])
        , test "can remove first item" <|
            \() ->
                Expect.equal (Array.fromList [ 2, 3 ]) <|
                    removeByIndex 0 (Array.fromList [ 1, 2, 3 ])
        , test "can remove middle item" <|
            \() ->
                Expect.equal (Array.fromList [ 1, 3 ]) <|
                    removeByIndex 1 (Array.fromList [ 1, 2, 3 ])
        , test "removing first middle works on even-length arrays" <|
            \() ->
                Expect.equal (Array.fromList [ 1, 3, 4 ]) <|
                    removeByIndex 1 (Array.fromList [ 1, 2, 3, 4 ])
        , test "removing last middle works on even-length arrays" <|
            \() ->
                Expect.equal (Array.fromList [ 1, 2, 4 ]) <|
                    removeByIndex 2 (Array.fromList [ 1, 2, 3, 4 ])
        , test "can remove last item" <|
            \() ->
                Expect.equal (Array.fromList [ 1, 2 ]) <|
                    removeByIndex 2 (Array.fromList [ 1, 2, 3 ])
        ]


updateByIndexTests : Test
updateByIndexTests =
    describe "updateByIndex"
        [ test "empty array returns empty array" <|
            \() ->
                Expect.equal Array.empty <|
                    updateByIndex 0 identity Array.empty
        , test "index greater than length has no effect" <|
            \() ->
                Expect.equal (Array.fromList [ 1, 2, 3, 4 ]) <|
                    updateByIndex 9001 ((+) 1) (Array.fromList [ 1, 2, 3, 4 ])
        , test "correct item is updated" <|
            \() ->
                Expect.equal (Array.fromList [ 1, 2, 4, 4 ]) <|
                    updateByIndex 2 ((+) 1) (Array.fromList [ 1, 2, 3, 4 ])
        ]


swapIndexesTests : Test
swapIndexesTests =
    let
        testArray =
            Array.fromList [ 5, 4, 3, 2, 1 ]
    in
        describe "swapIndexes"
            [ test "empty array returns empty array" <|
                \() ->
                    Expect.equal Array.empty <| swapIndexes 0 1 Array.empty
            , test "out of bounds initial has no effect" <|
                \() ->
                    Expect.equal testArray <| swapIndexes 42 1 testArray
            , test "out of bounds final has no effect" <|
                \() ->
                    Expect.equal testArray <| swapIndexes 0 42 testArray
            , test "correctly swaps elements" <|
                \() ->
                    Expect.equal (Array.fromList [ 5, 4, 1, 2, 3 ]) <|
                        swapIndexes 2 4 testArray
            ]
