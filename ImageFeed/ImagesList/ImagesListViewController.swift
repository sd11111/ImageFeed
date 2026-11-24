import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    // MARK: Private Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Private constants
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var presenter: ImagesListPresenterProtocol!

    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    private var reloadedPhotoIDs: Set<String> = []
    
    // MARK: Private variables
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem.title = nil
        tabBarItem.image = UIImage(named: "tab_editorial_active")

        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter.viewDidLoad()
    }

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard newCount > oldCount else {
            return
        }

        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            viewController.fullImageURL = URL(
                string: presenter.photos[indexPath.row].largeImageURL
            )
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: Private extensions
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(
        for cell: ImagesListCell,
        with indexPath: IndexPath
    ) {
        let photo = presenter.photos[indexPath.row]
        let photoID = photo.id

        cell.dateLabel.text = photo.createdAt.map {
            dateFormatter.string(from: $0)
        }

        cell.setIsLiked(photo.isLiked)

        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "stub")
        ) { [weak self, weak cell] result in
            guard case .success = result else {
                return
            }

            DispatchQueue.main.async { [weak self, weak cell] in
                guard
                    let self,
                    let cell,
                    let currentIndexPath = self.tableView.indexPath(
                        for: cell
                    ),
                    self.presenter.photos[currentIndexPath.row].id == photoID,
                    self.reloadedPhotoIDs.insert(photoID).inserted
                else {
                    return
                }

                self.tableView.reloadRows(
                    at: [currentIndexPath],
                    with: .none
                )
            }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let imageSize = presenter.photos[indexPath.row].size

        guard imageSize.width > 0 else {
            return 0
        }

        let imageInsets = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 8,
            right: 16
        )

        let imageViewWidth = tableView.bounds.width
            - imageInsets.left
            - imageInsets.right

        let scale = imageViewWidth / imageSize.width

        return imageSize.height * scale
            + imageInsets.top
            + imageInsets.bottom
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == presenter.photos.count - 1 {
            presenter.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let photo = presenter.photos[indexPath.row]

        UIBlockingProgressHUD.show()

        presenter.changeLike(
            photoId: photo.id,
            isLike: !photo.isLiked
        ) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else {
                return
            }

            switch result {
            case .success:
                let currentCell = self.tableView.cellForRow(
                    at: indexPath
                ) as? ImagesListCell

                currentCell?.setIsLiked(
                    self.presenter.photos[indexPath.row].isLiked
                )

            case .failure:
                let alert = UIAlertController(
                    title: "Не удалось изменить лайк",
                    message: "Попробуйте ещё раз.",
                    preferredStyle: .alert
                )

                alert.addAction(
                    UIAlertAction(
                        title: "ОК",
                        style: .default
                    )
                )

                self.present(alert, animated: true)
            }
        }
    }
}
