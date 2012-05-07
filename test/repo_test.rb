require File.expand_path('../test_helper', __FILE__)

class RepoTest < Test::Unit::TestCase

  def test_it_detects_the_new_pods_after_an_update
    repo = CocoaPodsNotifier::Repo.new
    Dir.chdir(repo.master_dir) { `git checkout 175726e > /dev/null 2>&1` }
    def repo.git_pull;  Dir.chdir(master_dir) { `git checkout fe31dfa > /dev/null 2>&1` };  end
    repo.update

    new_pods = repo.new_pods.map { |pod| pod.name }
    assert_equal %w[ AWSiOSSDK
                     BlockAlertsAnd-ActionSheets
                     CustomBadge
                     DTWebArchive
                     GAJavaScript
                     KIF
                     MwfTableViewController
                     NLTHTTPStubServer
                     NanoStore
                     OpenUDID
                     ReactiveCocoa
                     SFSocialFacebook
                     STLOAuth
                     ZKRevealingTableViewCell
                     ZKTextField ], new_pods

    Dir.chdir(repo.master_dir) { `git checkout master > /dev/null 2>&1` }
  end
end
