require 'spec_helper'

RSpec.describe DraftApprove::Persistor do
  let(:subject) { DraftApprove::Persistor }

  # The model & changes we use here are largely irrelevant to the tests, we just
  # need a model to create drafts of, and some known 'changes' that should get
  # saved to the database
  let(:model)   { FactoryBot.create(:role) }
  let(:changes) { { 'some_field' => ['old_value', 'new_value'] } }

  before(:each) do
    allow(DraftApprove::Serializers::Json).to receive(:changes_for_model).with(model).and_return(changes)
  end

  describe '.write_draft_from_model' do
    context 'when saving a draft with action_type CREATE' do
      let(:action_type) { Draft::CREATE }

      context "when the model hasn't already been persisted" do
        let(:model) { FactoryBot.build(:role) }

        it 'creates a draft with fields set correctly' do
          draft = subject.write_draft_from_model(action_type, model)

          expect(draft.draftable_type).to eq('Role')
          expect(draft.draftable_id).to be(nil)
          expect(draft.draftable).to eq(model)
          expect(draft.action_type).to eq(action_type)
          expect(draft.draft_changes).to eq(changes)
        end

        it 'persists the draft to the database with fields set correctly' do
          draft = subject.write_draft_from_model(action_type, model)

          expect(draft.persisted?).to be(true)
          draft.reload
          expect(draft.draftable_type).to eq('Role')
          expect(draft.draftable_id).to be(nil)
          expect(draft.draftable).to be(nil)
          expect(draft.action_type).to eq(action_type)
          expect(draft.draft_changes).to eq(changes)
        end

        it 'sets the draft field on the model to the draft object' do
          draft = subject.write_draft_from_model(action_type, model)
          expect(model.draft).to eq(draft)
        end
      end

      context 'when the model has already been persisted' do
        it 'raises AlreadyPersistedModelError' do
          expect do
            subject.write_draft_from_model(action_type, model)
          end.to raise_error(DraftApprove::AlreadyPersistedModelError)
        end
      end
    end

    context 'when saving a draft with action_type UPDATE' do
      let(:action_type) { Draft::UPDATE }

      context "when the model hasn't already been persisted" do
        let(:model) { FactoryBot.build(:role) }

        it 'raises UnpersistedModelError' do
          expect do
            subject.write_draft_from_model(action_type, model)
          end.to raise_error(DraftApprove::UnpersistedModelError)
        end
      end

      context 'when the model has already been persisted' do
        it 'creates a draft with fields set correctly' do
          draft = subject.write_draft_from_model(action_type, model)

          expect(draft.draftable_type).to eq('Role')
          expect(draft.draftable_id).to eq(model.id)
          expect(draft.draftable).to eq(model)
          expect(draft.action_type).to eq(action_type)
          expect(draft.draft_changes).to eq(changes)
        end

        it 'persists the draft to the database with fields set correctly' do
          draft = subject.write_draft_from_model(action_type, model)

          expect(draft.persisted?).to be(true)
          draft.reload
          expect(draft.draftable_type).to eq('Role')
          expect(draft.draftable_id).to eq(model.id)
          expect(draft.draftable).to eq(model)
          expect(draft.action_type).to eq(action_type)
          expect(draft.draft_changes).to eq(changes)
        end

        it 'sets the draft field on the model to the draft object' do
          draft = subject.write_draft_from_model(action_type, model)
          expect(model.draft).to eq(draft)
        end
      end
    end

    context 'when saving a draft with action_type DELETE' do
      let(:action_type) { Draft::DELETE }

      context "when the model hasn't already been persisted" do
        let(:model) { FactoryBot.build(:role) }

        it 'raises UnpersistedModelError' do
          expect do
            subject.write_draft_from_model(action_type, model)
          end.to raise_error(DraftApprove::UnpersistedModelError)
        end
      end

      context 'when the model has already been persisted' do
        it 'creates a draft with fields set correctly' do
          draft = subject.write_draft_from_model(action_type, model)

          expect(draft.draftable_type).to eq('Role')
          expect(draft.draftable_id).to eq(model.id)
          expect(draft.draftable).to eq(model)
          expect(draft.action_type).to eq(action_type)
          expect(draft.draft_changes).to eq(changes)
        end

        it 'persists the draft to the database with fields set correctly' do
          draft = subject.write_draft_from_model(action_type, model)

          expect(draft.persisted?).to be(true)
          draft.reload
          expect(draft.draftable_type).to eq('Role')
          expect(draft.draftable_id).to eq(model.id)
          expect(draft.draftable).to eq(model)
          expect(draft.action_type).to eq(action_type)
          expect(draft.draft_changes).to eq(changes)
        end

        it 'sets the draft field on the model to the draft object' do
          draft = subject.write_draft_from_model(action_type, model)
          expect(model.draft).to eq(draft)
        end
      end
    end

    context 'when model has an existing draft' do
      let!(:existing_draft) { FactoryBot.create(:draft, draftable: model) }
      let(:action_type) { Draft::UPDATE }  # Largely irrelevant, just any valid action type

      it 'raises ExistingDraftError' do
        expect do
          subject.write_draft_from_model(action_type, model)
        end.to raise_error(DraftApprove::ExistingDraftError)
      end
    end

    context 'when model is nil' do
      let(:action_type) { Draft::UPDATE }  # Largely irrelevant, just any valid action type

      it 'raises ArgumentError' do
        expect do
          subject.write_draft_from_model(action_type, nil)
        end.to raise_error(ArgumentError)
      end
    end

    context 'when action_type is invalid' do
      let(:action_type) { 'some invalid action_type' }

      it 'raises ArgumentError' do
        expect do
          subject.write_draft_from_model(action_type, model)
        end.to raise_error(ArgumentError)
      end
    end

    context 'when action_type is nil' do
      it 'raises ArgumentError' do
        expect do
          subject.write_draft_from_model(nil, model)
        end.to raise_error(ArgumentError)
      end
    end
  end
end