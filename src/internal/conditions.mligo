(* MIT License
   Copyright (c) 2022 Marigold <contact@marigold.dev>
   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
   the Software, and to permit persons to whom the Software is furnished to do so,
   subject to the following conditions:
   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE. *)


#import "../common/errors.mligo" "Errors"
#import "proposal_content.mligo" "Proposal_content"
#import "parameter.mligo" "Parameter"
#import "storage.mligo" "Storage"

type storage_types = Storage.Types.t
type storage_types_proposal = Storage.Types.proposal
type proposal_content = Proposal_content.Types.t

[@inline]
let only_signer (type a) (storage : a storage_types) : unit =
    assert_with_error (Set.mem (Tezos.get_sender ()) storage.signers) Errors.only_signer

[@inline]
let amount_must_be_zero_tez (an_amout : tez) : unit =
    assert_with_error (an_amout = 0tez) Errors.amount_must_be_zero_tez

[@inline]
let not_sign_yet (type a) (proposal : a storage_types_proposal) : unit =
    assert_with_error (not Set.mem (Tezos.get_sender ()) proposal.approved_signers) Errors.has_already_signed

[@inline]
let ready_to_execute (executed : bool) : unit =
    assert_with_error executed Errors.no_enough_approval_to_execute

[@inline]
let not_execute_yet (executed : bool) : unit =
    assert_with_error (not executed) Errors.not_execute_yet

[@inline]
let check_proposal (type a) (content: a proposal_content) : unit =
    match content with
    | Transfer _ -> ()
    | Execute _ -> ()
    | Execute_lambda _ -> ()
    | Adjust_threshold t ->
        assert_with_error (t > 0n) Errors.invalidated_threshold
    | Add_signers _ -> ()
    | Remove_signers _ -> ()

[@inline]
let check_proposals_content (type a) (proposals_content: (a proposal_content) list) : unit =
    List.iter check_proposal proposals_content

[@inline]
let check_setting (type a) (storage : a storage_types) : unit =
    let () = assert_with_error (Set.cardinal storage.signers > 0n) Errors.no_signer  in
    let () = assert_with_error (Set.cardinal storage.signers >= storage.threshold) Errors.no_enough_signer in
    let () = assert_with_error (storage.threshold > 0n) Errors.invalidated_threshold in
    ()
