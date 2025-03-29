# frozen_string_literal: true

require 'spec_helper'

describe SamlIdpMetadata::Parser do
  describe '.validate_xmlns' do
    subject { described_class.call(xml: xml).validate_xmlns }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }

      it { is_expected.to be_truthy }
    end

    context 'when valid xml w/ EntitiesDescriptor' do
      let(:xml) do
        File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_entities_descriptor.xml'))
      end

      it { is_expected.to be_truthy }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_xmlns.xml')) }

      it { is_expected.to be_falsey }
    end
  end

  describe '.ensure_params?' do
    subject { described_class.call(xml: xml).ensure_params? }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }

      it { is_expected.to be_truthy }
    end

    context 'when valid xml w/ entities_descriptor' do
      let(:xml) do
        File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_entities_descriptor.xml'))
      end

      it { is_expected.to be_truthy }
    end

    context 'when valid xml w/ sso_http_post_url not exists' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_ogate.xml')) }

      it { is_expected.to be_truthy }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }

      it { is_expected.to be_falsey }
    end
  end

  describe 'parsed value / entity_id' do
    subject { described_class.call(xml: xml).entity_id }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }

      it { is_expected.to eq 'https://example.com/saml2/metadata/issure-url' }
    end

    context 'when valid xml w/ EntitiesDescriptor' do
      let(:xml) do
        File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_entities_descriptor.xml'))
      end

      it { is_expected.to eq 'https://example.com/auth/realms/issure_url' }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }

      it { is_expected.to eq 'https://accounts.example.com/o/saml2?idpid=xxxxxx' }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }

      it { is_expected.to eq 'https://ap.ssso.example.com/sso/someone.example.com' }
    end

    context 'when valid xml w/ slo url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }

      it { is_expected.to eq 'http://www.example.com/someone-entity' }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }

      it { is_expected.to eq 'https://example.com/saml2/metadata/issure-url' }
    end

    context 'when invalid xml w/ entity_id is nil' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }

      it { is_expected.to be_nil }
    end
  end

  describe 'parsed value / sso_http_redirect_url' do
    subject { described_class.call(xml: xml).sso_http_redirect_url }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }

      it { is_expected.to eq 'https://example.com/saml2/http-redirect/sso/99999' }
    end

    context 'when valid xml w/ EntitiesDescriptor' do
      let(:xml) do
        File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_entities_descriptor.xml'))
      end

      it { is_expected.to eq 'https://example.com/auth/realms/key/protocol/saml' }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }

      it { is_expected.to eq 'https://accounts.example.com/o/saml2/idp?idpid=xxxxxx' }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }

      it { is_expected.to eq 'https://ap.ssso.example.com/sso/someone.example.com/login' }
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }

      it { is_expected.to eq 'https://someone-entity.example.com/app/saml_example_app/somecode/sso/saml' }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }

      it { is_expected.to be_nil }
    end

    context 'when invalid xml w/ entity_id is nil' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }

      it { is_expected.to eq 'https://example.com/saml2/http-redirect/sso/99999' }
    end
  end

  describe 'parsed value / sso_http_post_url' do
    subject { described_class.call(xml: xml).sso_http_post_url }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }

      it { is_expected.to eq 'https://example.com/saml2/http-post/sso/99999' }
    end

    context 'when valid xml w/ EntitiesDescriptor' do
      let(:xml) do
        File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_entities_descriptor.xml'))
      end

      it { is_expected.to eq 'https://example.com/auth/realms/key/protocol/saml' }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }

      it { is_expected.to eq 'https://accounts.example.com/o/saml2/idp?idpid=xxxxxx' }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }

      it { is_expected.to eq 'https://ap.ssso.example.com/sso/someone.example.com/login' }
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }

      it { is_expected.to eq 'https://someone-entity.example.com/app/saml_example_app/somecode/sso/saml' }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }

      it { is_expected.to be_nil }
    end

    context 'when invalid xml w/ entity_id is nil' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }

      it { is_expected.to eq 'https://example.com/saml2/http-post/sso/99999' }
    end
  end

  describe 'parsed value / certificate' do
    subject { described_class.call(xml: xml).x509_certificate }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }

      it { is_expected.to eq 'X509Certificate-X509Certificate=' }
    end

    context 'when valid xml w/ EntitiesDescriptor' do
      let(:xml) do
        File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_entities_descriptor.xml'))
      end

      it { is_expected.to eq 'X509Certificate-X509Certificate=' }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }

      it { is_expected.to eq 'Certificate001-Certificate001=' }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }

      it { is_expected.to eq 'Certificate000-Certificate000' }
    end

    context 'when valid xml w/ sso single sign on service has 2 element. (like a ogate xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_ogate.xml')) }

      it { is_expected.to eq 'Certificate000-Certificate000' }
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }

      it { is_expected.to eq 'Certificate009=Certificate009==' }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }

      it { is_expected.to be_nil }
    end

    context 'when invalid xml w/ entity_id is nil' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }

      it { is_expected.to eq 'X509Certificate-X509Certificate=' }
    end
  end

  describe 'parsed value / slo_url' do
    subject { described_class.call(xml: xml).slo_url }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }

      it { is_expected.to eq 'https://example.com/saml2/http-redirect/slo/99999' }
    end

    context 'when valid xml w/ EntitiesDescriptor' do
      let(:xml) do
        File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_entities_descriptor.xml'))
      end

      it { is_expected.to eq 'https://example.com/auth/realms/key/protocol/saml' }
    end

    context 'when valid xml w/ multiple singlelogout line' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_multiple_slo.xml')) }

      it { is_expected.to eq 'https://example.com/saml2/http-redirect/slo/99999' }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }

      it { is_expected.to be_nil }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }

      it { is_expected.to be_nil }
    end

    context 'when valid xml w/ sso single sign on service has 2 element. (like a ogate xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_ogate.xml')) }

      it { is_expected.to eq 'https://auth.example.com/saml/saml2/idp/SingleLogoutService.php' }
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }

      it { is_expected.to be_nil }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }

      it { is_expected.to be_nil }
    end

    context 'when invalid xml w/ entity_id is nil' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }

      it { is_expected.to eq 'https://example.com/saml2/http-redirect/slo/99999' }
    end
  end

  describe 'parsed value / nameid_format' do
    subject { described_class.call(xml: xml).nameid_format }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }

      it { is_expected.to eq 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress' }
    end

    context 'when valid xml w/ EntitiesDescriptor' do
      let(:xml) do
        File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_entities_descriptor.xml'))
      end

      it { is_expected.to eq 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress' }
    end

    context 'when valid xml w/ multiple singlelogout line' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_multiple_slo.xml')) }

      it { is_expected.to eq 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress' }
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }

      it { is_expected.to eq 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress' }
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }

      it { is_expected.to eq 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress' }
    end

    context 'when valid xml w/ sso single sign on service has 2 element. (like a ogate xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_ogate.xml')) }

      it { is_expected.to eq 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient' }
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }

      it { is_expected.to eq 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress' }
    end

    context 'when invalid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }

      it { is_expected.to be_nil }
    end

    context 'when invalid xml w/ entity_id is nil' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }

      it { is_expected.to eq 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress' }
    end
  end

  describe '.build_params' do
    subject(:build_params) { described_class.call(xml: xml).build_params }

    context 'when valid xml' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid.xml')) }

      it 'includes correct entity_id' do
        expect(build_params).to include(entity_id: 'https://example.com/saml2/metadata/issure-url')
      end

      it 'includes correct sso_http_redirect_url' do
        expect(build_params).to include(sso_http_redirect_url: 'https://example.com/saml2/http-redirect/sso/99999')
      end

      it 'includes correct sso_http_post_url' do
        expect(build_params[:sso_http_post_url]).to eq 'https://example.com/saml2/http-post/sso/99999'
      end

      it 'includes the original metadata' do
        expect(build_params[:metadata]).to eq xml
      end
    end

    context 'when valid xml w/ EntitiesDescriptor' do
      let(:xml) do
        File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_entities_descriptor.xml'))
      end

      it 'includes correct entity_id' do
        expect(build_params).to include(entity_id: 'https://example.com/auth/realms/issure_url')
      end

      it 'includes correct sso_http_redirect_url' do
        expect(build_params).to include(sso_http_redirect_url: 'https://example.com/auth/realms/key/protocol/saml')
      end

      it 'includes correct sso_http_post_url' do
        expect(build_params[:sso_http_post_url]).to eq 'https://example.com/auth/realms/key/protocol/saml'
      end

      it 'includes the original metadata' do
        expect(build_params[:metadata]).to eq xml
      end
    end

    context 'when valid xml w/ multiple X509Certificate (like a G Suite xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_gsuite.xml')) }

      it 'includes correct entity_id' do
        expect(build_params).to include(entity_id: 'https://accounts.example.com/o/saml2?idpid=xxxxxx')
      end

      it 'includes correct sso_http_redirect_url' do
        expect(build_params).to include(sso_http_redirect_url: 'https://accounts.example.com/o/saml2/idp?idpid=xxxxxx')
      end

      it 'includes correct sso_http_post_url' do
        expect(build_params[:sso_http_post_url]).to eq 'https://accounts.example.com/o/saml2/idp?idpid=xxxxxx'
      end

      it 'includes the original metadata' do
        expect(build_params[:metadata]).to eq xml
      end
    end

    context 'when valid xml w/ sol url not exists (like a Okta xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_okta.xml')) }

      it 'includes correct entity_id' do
        expect(build_params).to include(entity_id: 'http://www.example.com/someone-entity')
      end

      it 'includes correct sso_http_redirect_url' do
        expect(build_params).to include(
          sso_http_redirect_url: 'https://someone-entity.example.com/app/saml_example_app/somecode/sso/saml'
        )
      end

      it 'includes correct sso_http_post_url' do
        expect(build_params[:sso_http_post_url]).to eq 'https://someone-entity.example.com/app/saml_example_app/somecode/sso/saml'
      end

      it 'includes the original metadata' do
        expect(build_params[:metadata]).to eq xml
      end
    end

    context 'when valid xml w/ sso single sign on service has 1 element. (like a SOME ONE xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_someone.xml')) }

      it 'includes correct entity_id' do
        expect(build_params).to include(entity_id: 'https://ap.ssso.example.com/sso/someone.example.com')
      end

      it 'includes correct sso_http_redirect_url' do
        expect(build_params).to include(
          sso_http_redirect_url: 'https://ap.ssso.example.com/sso/someone.example.com/login'
        )
      end

      it 'includes correct sso_http_post_url' do
        expect(build_params[:sso_http_post_url]).to eq 'https://ap.ssso.example.com/sso/someone.example.com/login'
      end

      it 'includes the original metadata' do
        expect(build_params[:metadata]).to eq xml
      end
    end

    context 'when valid xml w/ sso single sign on service has 2 element. (like a ogate xml metadata)' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_valid_ogate.xml')) }

      it 'includes correct entity_id' do
        expect(build_params).to include(entity_id: 'https://auth.example.com/99999999999')
      end

      it 'includes correct sso_http_redirect_url' do
        expect(build_params).to include(
          sso_http_redirect_url: 'https://auth.example.com/saml/saml2/idp/SSOService.php/99999999999'
        )
      end

      it 'includes correct sso_http_post_url' do
        expect(build_params[:sso_http_post_url]).to eq 'https://auth.example.com/saml/saml2/idp/SSOService.php/99999999999'
      end

      it 'includes the original metadata' do
        expect(build_params[:metadata]).to eq xml
      end
    end

    context 'when invalid xml with no elements' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid.xml')) }

      it 'includes entity_id' do
        expect(build_params).to include(entity_id: 'https://example.com/saml2/metadata/issure-url')
      end

      it 'has nil sso_http_redirect_url' do
        expect(build_params[:sso_http_redirect_url]).to be_nil
      end

      it 'has nil sso_http_post_url' do
        expect(build_params[:sso_http_post_url]).to be_nil
      end

      it 'includes the original metadata' do
        expect(build_params[:metadata]).to eq xml
      end
    end

    context 'when invalid xml with missing entity_id' do
      let(:xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'saml_idp_metadata_invalid_entity_id.xml')) }

      it 'has nil entity_id' do
        expect(build_params[:entity_id]).to be_nil
      end

      it 'includes correct sso_http_redirect_url' do
        expect(build_params).to include(
          sso_http_redirect_url: 'https://example.com/saml2/http-redirect/sso/99999'
        )
      end

      it 'includes correct sso_http_post_url' do
        expect(build_params[:sso_http_post_url]).to eq 'https://example.com/saml2/http-post/sso/99999'
      end

      it 'includes the original metadata' do
        expect(build_params[:metadata]).to eq xml
      end
    end
  end
end
